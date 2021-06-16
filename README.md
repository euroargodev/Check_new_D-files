# Check_new_D-files
The program executes a first loop to check for consistency among the variables (correct 99999 location and relative QC, arrays size comparison, good or bad QC between R-file and D-file).
The profile QC is also verified according to the good data percentage, obtained  by the adjusted salinity QC flag.
The GPS location must be inside the realistic geographical domain and the position QC must be defined accordingly.

The second loop generates the graphs. The R-file and the D-files are plotted together while the bad data are shown to the right of the figure.
A second figure shows 3x2 subplots comparing the QC between R-file and D-file in the first row and the errors in the second row; each column represent the parameter.
