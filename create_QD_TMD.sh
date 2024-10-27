k#!/bin/bash

# --- Introduction ---
# This script generates the necessary file structure, including POSCAR, INCAR, KPOINTS, POTCAR, and run.sh files,
# in a directory hierarchy for nanotriangle simulations. It supports both Janus (MXY) and pristine (MX2) configurations
# by adapting the directory structure, POSCAR file, and magnetic moment configuration (MAGMOM) in INCAR.

# --- Step 1: Gather User Input for Element Configuration ---
# Request user input for metal (M), chalcogen X, and optional second chalcogen Y to distinguish between Janus and pristine phases.
# This input will determine the appropriate POSCAR template and directory name.

echo "Enter the elements of your nanotriangle in MXY or MX2 format:"
read -p "Transition metal (M): " m
read -p "Chalcogen X: " x
read -p "Chalcogen Y (leave blank if pristine MX2): " y

# Define the directory name and POSCAR structure type based on user input.
if [ -z "$y" ]; then
    # If Y is empty, we are working with a pristine MX2 phase.
    mater="${m}${x}2"
    directory="MX2"
else
    # If Y is provided, this indicates a Janus MXY structure.
    mater="${m}${x}${y}"
    directory="MXY"
fi

# Define the base path where files will be created and locate POSCAR templates.
base_path="/tmpu/jong_g/jong/Jair/nanotriangulos"
min=4
max=10

# --- Step 2: Navigate to POSCAR Template Directory ---
# Ensure that the script is in the correct base directory (MXY or MX2) for accessing POSCAR templates.
cd "$base_path/$directory" || { echo "Error: Unable to access directory $base_path/$directory"; exit 1; }

# Process directories 'a' and 'b' for both Janus and pristine structures.
for folder in a b; do
    cd "$folder" || { echo "Error: Unable to access subdirectory $folder"; exit 1; }
    
    for i in $(seq $min $max); do
        # Navigate into each numbered subdirectory (e.g., a/4, b/5, etc.).
        cd "$i" || { echo "Error: Unable to access subdirectory $i"; exit 1; }
        
        # Define model path for POSCAR and replace placeholders in POSCAR template.
        # The placeholders 'M', 'X', 'Y', and 'triangle' are replaced with actual element names and the model path.
        model="$mater/$folder/$i"
        sed -e "s|M|$m|" -e "s|X|$x|" -e "s|Y|$y|" -e "s|triangle|$model|" POSCAR > POSCAR2
        
        # Move POSCAR2 to the final POSCAR filename in the target directory.
        if [[ -f "POSCAR2" ]]; then
            mkdir -p "$base_path/$mater/$folder/$i"
            mv POSCAR2 "$base_path/$mater/$folder/$i/POSCAR"
            echo "POSCAR file generated and moved to $base_path/$mater/$folder/$i/POSCAR"
        else
            echo "Error: POSCAR2 was not generated correctly in $i"
        fi

        # --- Step 3: Generate Additional Required Files (INCAR, KPOINTS, run.sh, POTCAR) ---
        # In each subdirectory, the script creates INCAR, KPOINTS, run.sh, and POTCAR files.
        subdir="$base_path/$mater/$folder/$i"
        
        # Create KPOINTS file for defining the k-point sampling in the Brillouin zone.
        cat > "$subdir/KPOINTS" <<EOF
kpoints nanotriangle ${mater}${folder}$i
0
Gamma
1 1 1
EOF

        # Generate run.sh file to submit simulation jobs, setting necessary HPC job options and module dependencies.
        cat > "$subdir/run.sh" <<EOF
#!/bin/bash
#BSUB -oo x.o
#BSUB -eo x.e
#BSUB -q q_residual
#BSUB -n 32
#BSUB -J ${mater}${folder}$i

module load vasp/5.4.4
module load mkl/2017_update3
module load mpi/intel-2017_update3

EXEC=/tmpu/jong_g/jong/apps/vasp/5.4.4/vasp_std
mpirun -np \$LSB_DJOB_NUMPROC \$EXEC < INCAR > INCAR.out
EOF
        chmod +x "$subdir/run.sh"

 

