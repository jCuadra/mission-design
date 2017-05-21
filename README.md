# mission-design
MATLAB tool that designs an interplanetary mission given a set of constraints.  Updated and tested on R2016b

Original paper: [A Novel Application of Binary Integer Programming](http://ccar.colorado.edu/ASEN5050/projects/projects_2014/Klein_Patrick/BIP.pdf)

Website: [Interplanetary Trajectory Optimization](http://ccar.colorado.edu/ASEN5050/projects/projects_2014/Klein_Patrick/index.html)

## How to Run

1. Run missionGUI from the command line
2. Set the parameters in the window
    * Start Date
    * Time Step in days
    * Duration in days (must be multiple of time step)
    * Select the start and end planet(s) using the radial buttons
    * Select other planets to visit
3. Adjust optional settings (others may not yet be implemented)
    * Minimize dv or c3 - *option to use c3 for departure cost*
    * TOF Cost Factor - *adjust cost to favor shorter transits*
    * No intermediate orbits - *prevents orbits on target planets*
4. Command window will update with progress... Be patient for dv calculations
5. After optimization is complete, press Return key to view mission animation
  
  
## Sample Window and Output:

![Sample Window](Sample-window.png)

```
Total number of variables: 5994
Estimated number of deltaV calculations: 3996
Calculating cost vector...
Calculations finished.
Elapsed time is 11.180726 seconds.
Reduced number of variables: 4973
 
Optimization started.
LP:                Optimal objective value is 25.579661.                                            


Optimal solution found.

Intlinprog stopped at the root node because the objective value is within a gap tolerance of the optimal value,
options.AbsoluteGapTolerance = 0 (the default value). The intcon variables are integer within tolerance,
options.IntegerTolerance = 1e-05 (the default value).

Elapsed time is 0.057118 seconds.

Orbit Earth from 1/1/2016 until 11/26/2016.
Transit from Earth to Venus from 11/26/2016 until 5/25/2017.
Orbit Venus from 5/25/2017 until 8/23/2017.
Transit from Venus to Mars from 8/23/2017 until 3/21/2018.
Transit from Mars to Earth from 3/21/2018 until 10/17/2018.
Orbit Earth from 10/17/2018 until 12/16/2018.

Total cost: 25.5797

Press Return key to watch mission animation.
```
