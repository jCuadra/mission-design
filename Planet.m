% Planet.m

classdef Planet < Orbit

    properties
        index
        name
        a0, e0, i0, O0, w0, L0
        ad, ed, id, Od, wd, Ld
    end % properties

    methods

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function obj = Planet(i, T)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            tau = 2 * pi;
            obj.index = i;
            switch i
                case 1
                    obj.name = 'Mercury';
                    obj.a0 =   0.38709927 * 1.496e8;
                    obj.e0 =   0.20563593;
                    obj.i0 =   7.00497902 * tau / 360;
                    obj.O0 =  48.33076593 * tau / 360;
                    obj.w0 =  77.45779628 * tau / 360;
                    obj.L0 = 252.25032350 * tau / 360;
                    obj.ad =      0.00000037 * 1.496e8;
                    obj.ed =      0.00001906;
                    obj.id =     -0.00594749 * tau / 360;
                    obj.Od =     -0.12534081 * tau / 360;
                    obj.wd =      0.16047689 * tau / 360;
                    obj.Ld = 149472.67411175 * tau / 360;
                case 2
                    obj.name = 'Venus';
                    obj.a0 =   0.72333566 * 1.496e8;
                    obj.e0 =   0.00677672;
                    obj.i0 =   3.39467605 * tau / 360;
                    obj.O0 =  76.67984255 * tau / 360;
                    obj.w0 = 131.60246718 * tau / 360;
                    obj.L0 = 181.97909950 * tau / 360;
                    obj.ad =     0.00000390 * 1.496e8;
                    obj.ed =    -0.00004107;
                    obj.id =    -0.00078890 * tau / 360;
                    obj.Od =    -0.27769418 * tau / 360;
                    obj.wd =     0.00268329 * tau / 360;
                    obj.Ld = 58517.81538729 * tau / 360;
                case 3
                    obj.name = 'Earth';
                    obj.a0 =   1.00000261 * 1.496e8;
                    obj.e0 =   0.01671123;
                    obj.i0 =  -0.00001531 * tau / 360;
                    obj.O0 =   0.0 * tau / 360;
                    obj.w0 = 102.93768193 * tau / 360;
                    obj.L0 = 100.46457166 * tau / 360;
                    obj.ad =     0.00000562 * 1.496e8;
                    obj.ed =    -0.00004392;
                    obj.id =    -0.01294668 * tau / 360;
                    obj.Od =     0.0 * tau / 360;
                    obj.wd =     0.32327364 * tau / 360;
                    obj.Ld = 35999.37244981 * tau / 360;
                case 4
                    obj.name = 'Mars';
                    obj.a0 =   1.52371034 * 1.496e8;
                    obj.e0 =   0.09339410;
                    obj.i0 =   1.84969142 * tau / 360;
                    obj.O0 =  49.55953891 * tau / 360;
                    obj.w0 = -23.94362959 * tau / 360;
                    obj.L0 =  -4.55343205 * tau / 360;
                    obj.ad =     0.0001847 * 1.496e8;
                    obj.ed =     0.00007882;
                    obj.id =    -0.00813131 * tau / 360;
                    obj.Od =    -0.29257343 * tau / 360;
                    obj.wd =     0.44441088 * tau / 360;
                    obj.Ld = 19140.30268499 * tau / 360;
                case 5
                    obj.name = 'Jupiter';
                    obj.a0 =   5.20288700 * 1.496e8;
                    obj.e0 =   0.04838624;
                    obj.i0 =   1.30439695 * tau / 360;
                    obj.O0 = 100.47390909 * tau / 360;
                    obj.w0 =  14.72847983 * tau / 360;
                    obj.L0 =  34.39644501 * tau / 360;
                    obj.ad =   -0.00011607 * 1.496e8;
                    obj.ed =   -0.00013253;
                    obj.id =   -0.00183714 * tau / 360;
                    obj.Od =    0.20469106 * tau / 360;
                    obj.wd =    0.21252668 * tau / 360;
                    obj.Ld = 3034.74612775 * tau / 360;
                case 6
                    obj.name = 'Saturn';
                    obj.a0 =   9.53667594 * 1.496e8;
                    obj.e0 =   0.05386179;
                    obj.i0 =   2.48599187 * tau / 360;
                    obj.O0 = 113.66242448 * tau / 360;
                    obj.w0 =  92.59887831 * tau / 360;
                    obj.L0 =  49.95424423 * tau / 360;
                    obj.ad =   -0.00125060 * 1.496e8;
                    obj.ed =   -0.00050991;
                    obj.id =    0.00193609 * tau / 360;
                    obj.Od =   -0.28867794 * tau / 360;
                    obj.wd =   -0.41897216 * tau / 360;
                    obj.Ld = 1222.49362201 * tau / 360;
                case 7
                    obj.name = 'Uranus';
                    obj.a0 =  19.18916464 * 1.496e8;
                    obj.e0 =   0.04725744;
                    obj.i0 =   0.77263783 * tau / 360;
                    obj.O0 =  74.01692503 * tau / 360;
                    obj.w0 = 170.95427630 * tau / 360;
                    obj.L0 = 313.23810451 * tau / 360;
                    obj.ad =  -0.00196176 * 1.496e8;
                    obj.ed =  -0.00004397;
                    obj.id =  -0.00242939 * tau / 360;
                    obj.Od =   0.04240589 * tau / 360;
                    obj.wd =   0.40805281 * tau / 360;
                    obj.Ld = 428.48202785 * tau / 360;
                case 8
                    obj.name = 'Neptune';
                    obj.a0 =  30.06992276 * 1.496e8;
                    obj.e0 =   0.00859048;
                    obj.i0 =   1.77004347 * tau / 360;
                    obj.O0 = 131.78422574 * tau / 360;
                    obj.w0 =  44.96476227 * tau / 360;
                    obj.L0 = -55.12002969 * tau / 360;
                    obj.ad =   0.00026291 * 1.496e8;
                    obj.ed =   0.00005105;
                    obj.id =   0.00035372 * tau / 360;
                    obj.Od =  -0.00508664 * tau / 360;
                    obj.wd =  -0.32241464 * tau / 360;
                    obj.Ld = 218.45945325 * tau / 360;
                case 9
                    obj.name = 'Pluto';
                    obj.a0 =  39.48211675 * 1.496e8;
                    obj.e0 =   0.24882730;
                    obj.i0 =  17.14001206 * tau / 360;
                    obj.O0 = 110.30393684 * tau / 360;
                    obj.w0 = 224.06891629 * tau / 360;
                    obj.L0 = 238.92903833 * tau / 360;
                    obj.ad =  -0.00031596 * 1.496e8;
                    obj.ed =   0.00005170;
                    obj.id =   0.00004818 * tau / 360;
                    obj.Od =  -0.01183482 * tau / 360;
                    obj.wd =  -0.04062942 * tau / 360;
                    obj.Ld = 145.20780515 * tau / 360;
            end % switch

            if nargin > 1
                obj.setEpoch(T);
            end

        end % constructor

        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        function obj = setEpoch(obj, T)
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            tau = 2 * pi;

            a = obj.a0 + obj.ad * T;
            e = obj.e0 + obj.ed * T;
            i = mod(obj.i0 + obj.id * T, tau);
            O = mod(obj.O0 + obj.Od * T, tau);
            w = mod(obj.w0 + obj.wd * T, tau);
            L = mod(obj.L0 + obj.Ld * T, tau);

            wa = mod(w - O, tau);
            Me  = mod(L - w, tau);

            nu = obj.meanAnomalyToTrueAnomaly(Me, e);

            obj.a_ = a;
            obj.e_ = e;
            obj.i_ = i;
            obj.O_ = O;
            obj.w_ = wa;
            obj.nu_ = nu;
        end % propagateState

    end % methods
end % Planet
