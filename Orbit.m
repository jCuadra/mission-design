% Orbit.m

classdef Orbit < handle

    properties
        % Gravitational parameter
        mu = 132712440018.9;
    end % properties

    properties (Dependent)
        % Orbital elements
        a, e, i, O, w, nu
        % State vectors
        r, v
        % Orbital period
        T
        % Angular momentum
        h
        % Intermedate values
        hVec, N, Nv, eVec, vr
    end % dependent properties

    properties (Access = protected)
        a_, e_, i_, O_, w_, nu_
        r_, v_
        T_, h_
        hVec_, N_, Nv_, eVec_, vr_
    end % protected properties

    methods

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function obj = propagateState(obj, dt)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            tau = 2 * pi;

            % Calculate mean anomaly from true anomaly
            meanAnomaly = obj.trueAnomalyToMeanAnomaly(obj.nu, obj.e);

            % Increment mean anomaly by dt days
            meanAnomaly = mod(meanAnomaly + tau / obj.T * dt * 24 * 3600, tau);

            % Convert new mean anomaly back into true anomaly
            obj.nu = obj.meanAnomalyToTrueAnomaly(meanAnomaly, obj.e);

        end % propagateState

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function obj = clearOrbitalElements(obj)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            obj.a_ = [];
            obj.e_ = [];
            obj.i_ = [];
            obj.O_ = [];
            obj.w_ = [];
            obj.nu_ = [];
            obj.T_ = [];
            obj.h_ = [];
            obj.hVec_ = [];
            obj.N_ = [];
            obj.Nv_ = [];
            obj.eVec_ = [];
            obj.vr_ = [];
        end % clearOrbitalElements

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function obj = clearStateVector(obj)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            obj.r_ = [];
            obj.v_ = [];
        end % clearStateVector

        function val = get.a(obj)
            if isempty(obj.a_)
                obj.a_ = obj.h ^ 2 / obj.mu / (1 - obj.e ^ 2);
            end
            val = obj.a_;
        end % get.a

        function val = get.e(obj)
            if isempty(obj.e_)
                obj.e_ = norm(obj.eVec);
            end
            val = obj.e_;
        end % get.e

        function val = get.i(obj)
            if isempty(obj.i_)
                obj.i_ = acos(obj.hVec(3) / obj.h);
            end
            val = obj.i_;
        end % get.i

        function val = get.O(obj)
            if isempty(obj.O_)
                obj.O_ = acos(obj.Nv(1) / obj.N);
                if obj.Nv(2) < 0
                    obj.O_ = 2 * pi - obj.O_;
                end
            end
            val = obj.O_;
        end % get.O

        function val = get.w(obj)
            if isempty(obj.w_)
                obj.w_ = acos(dot(obj.Nv / obj.N, obj.eVec / obj.e));
                if obj.eVec(3) < 0
                    obj.w_ = 2 * pi - obj.w_;
                end
            end
            val = obj.w_;
        end % get.w

        function val = get.nu(obj)
            if isempty(obj.nu_)
                obj.nu_ = acos(dot(obj.eVec / obj.e, obj.r / norm(obj.r)));
                if obj.vr < 0
                    obj.nu_ = 2 * pi - obj.nu_;
                end
            end
            val = obj.nu_;
        end % get.nu

        function val = get.r(obj)
            if isempty(obj.r_)
                rMag = obj.a * (1 - obj.e ^ 2) / (1 + obj.e * cos(obj.nu));
                ri = cos(obj.nu + obj.w) * cos(obj.O) - sin(obj.nu + obj.w) * sin(obj.O) * cos(obj.i);
                rj = cos(obj.nu + obj.w) * sin(obj.O) + sin(obj.nu + obj.w) * cos(obj.O) * cos(obj.i);
                rk = sin(obj.nu + obj.w) * sin(obj.i);
                obj.r_ = rMag * [ri; rj; rk];
            end
            val = obj.r_;
        end % get.r

        function val = get.v(obj)
            if isempty(obj.v_)
                p = obj.h ^ 2 / obj.mu;
                vMag = (obj.mu / p * (1 + 2 * obj.e * cos(obj.nu) + obj.e ^ 2)) .^ 0.5;
                g = atan(obj.e * sin(obj.nu) / (1 + obj.e * cos(obj.nu)));
                vi = -(sin(obj.nu + obj.w - g) * cos(obj.O) + cos(obj.nu + obj.w - g) * sin(obj.O) * cos(obj.i));
                vj = -(sin(obj.nu + obj.w - g) * sin(obj.O) - cos(obj.nu + obj.w - g) * cos(obj.O) * cos(obj.i));
                vk = cos(obj.nu + obj.w - g) * sin(obj.i);
                obj.v_ = vMag * [vi; vj; vk];
            end
            val = obj.v_;
        end % get.v

        function val = get.T(obj)
            if isempty(obj.T_)
                obj.T_ = 2 * pi / sqrt(obj.mu) * obj.a ^ (3 / 2);
            end
            val = obj.T_;
        end % get.T

        function val = get.h(obj)
            if isempty(obj.h_)
                if isempty(obj.a_) || isempty(obj.e_)
                    obj.h_ = norm(obj.hVec);
                else
                    obj.h_ = sqrt(obj.mu * obj.a * (1 - obj.e ^ 2));
                end
            end
            val = obj.h_;
        end % get.h

        function val = get.hVec(obj)
            if isempty(obj.hVec_)
                obj.hVec_ = cross(obj.r, obj.v);
            end
            val = obj.hVec_;
        end % get.hVec

        function val = get.N(obj)
            if isempty(obj.N_)
                obj.N_ = norm(obj.Nv);
            end
            val = obj.N_;
        end % get.N

        function val = get.Nv(obj)
            if isempty(obj.Nv_)
                obj.Nv_ = cross([0; 0; 1], obj.hVec);
            end
            val = obj.Nv_;
        end % get.Nv

        function val = get.eVec(obj)
            if isempty(obj.eVec_)
                rMag = norm(obj.r);
                obj.eVec_ = (1 / obj.mu) * ((norm(obj.v) ^ 2 - obj.mu / rMag) * obj.r - rMag * obj.vr * obj.v);
            end
            val = obj.eVec_;
        end % get.eVec

        function val = get.vr(obj)
            if isempty(obj.vr_)
                obj.vr_ = dot(obj.r, obj.v) / norm(obj.r);
            end
            val = obj.vr_;
        end % get.vr

        function set.r(obj, val)
            obj.r_ = val;
            obj.clearOrbitalElements();
        end % set.r

        function set.v(obj, val)
            obj.v_ = val;
            obj.clearOrbitalElements();
        end % set.v

        function set.nu(obj, val)
            obj.nu_ = val;
            obj.clearStateVector();
        end % set.nu

    end % methods

    methods (Static)

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function [transferDepart, transferArrive, deltaV] = transferOrbit(planetDepart, planetArrive, dt, dtOption, c3Option)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            % Get transfer orbit for short-way
            [V1Short, V2Short, ~, error] = lambert(planetDepart.r', planetArrive.r', dt, 0, planetArrive.mu);
            if error < 1
                disp('Error getting transfer orbit for short-way.')
            end

            transferDepartShort = Orbit();
            transferDepartShort.r = planetDepart.r;
            transferDepartShort.v = V1Short';

            transferArriveShort = Orbit();
            transferArriveShort.r = planetArrive.r;
            transferArriveShort.v = V2Short';

            % Get transfer orbit for long-way
            [V1Long, V2Long, ~, error] = lambert(planetDepart.r', planetArrive.r', -dt, 0, planetArrive.mu);
            if error < 1
                disp('Error getting transfer orbit for long-way.')
            end

            transferDepartLong = Orbit();
            transferDepartLong.r = planetDepart.r;
            transferDepartLong.v = V1Long';

            transferArriveLong = Orbit();
            transferArriveLong.r = planetArrive.r;
            transferArriveLong.v = V2Long';

            % Calculate deltaV for both transfer orbits
            deltaVShort = Orbit.transferDeltaV(transferDepartShort, transferArriveShort, planetDepart, planetArrive, dt, dtOption, c3Option);
            deltaVLong = Orbit.transferDeltaV(transferDepartLong, transferArriveLong, planetDepart, planetArrive, dt, dtOption, c3Option);

            % Return the more efficient transfer
            if deltaVShort < deltaVLong
                transferDepart = transferDepartShort;
                transferArrive = transferArriveShort;
                deltaV = deltaVShort;
            else
               transferDepart = transferDepartLong;
               transferArrive = transferArriveLong;
               deltaV = deltaVLong;
            end

        end % transferOrbit

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function [deltaV] = transferDeltaV(transferDepart, transferArrive, planetDepart, planetArrive, dt, dtOption, c3Option)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            % DeltaV cost methods
            if c3Option
                % Only use c3
                deltaV = norm(transferDepart.v - planetDepart.v) ^ 2; % + norm(transferArrive.v - planetArrive.v);
            else
                % Sum of individual dv
                deltaV = norm(transferDepart.v - planetDepart.v) + norm(transferArrive.v - planetArrive.v);
            end

            % TODO: just set dtOption to 0 or 1
            if dtOption == 2
                % Increase cost with tof
                deltaV = deltaV * sqrt(dt);
            end

        end % transferDeltaV

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function [trueAnomaly] = meanAnomalyToTrueAnomaly(meanAnomaly, eccentricity)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            tau = 2 * pi;
            if meanAnomaly > tau / 2
                meanAnomaly = meanAnomaly - tau;
            end
            f = @(theta) 2 * atan(sqrt((1 - eccentricity) / (1 + eccentricity)) * tan(theta / 2)) ...
                - (eccentricity * sqrt(1 - eccentricity ^ 2) * sin(theta)) / (1 + eccentricity * cos(theta)) ...
                - meanAnomaly;
            trueAnomaly = fsolve(f, meanAnomaly, optimset('Display', 'off'));
            trueAnomaly = mod(trueAnomaly, tau);
        end % meanAnomalyToTrueAnomaly

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function [meanAnomaly] = trueAnomalyToMeanAnomaly(trueAnomaly, eccentricity)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            % Define tau
            tau = 2 * pi;
            % Calculate mean anomaly
            if eccentricity < 1
                meanAnomaly = 2 * atan(sqrt((1 - eccentricity) / (1 + eccentricity)) * tan(trueAnomaly / 2)) ...
                    - (eccentricity * sqrt(1 - eccentricity ^ 2) * sin(trueAnomaly)) / (1 + eccentricity * cos(trueAnomaly));
            else
                F = acosh((eccentricity + cos(trueAnomaly)) / (1 + eccentricity * cos(trueAnomaly)));
                meanAnomaly = eccentricity * sinh(F) - F;
            end
            % Constrain meanAnomaly between 0 and tau
            meanAnomaly = mod(meanAnomaly, tau);
        end % trueAnomalyToMeanAnomaly

    end % static methods

end % Orbit
