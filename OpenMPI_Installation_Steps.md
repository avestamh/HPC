
# Installation Steps for OpenMPI

## Download OpenMPI:

Visit the OpenMPI website and download the latest stable release.
Alternatively, you can use `wget` in the command line:

```bash
wget https://download.open-mpi.org/release/open-mpi/vX.X.X/openmpi-X.X.X.tar.gz
```
Replace `X.X.X` with the desired version number.

## Extract the Archive:

```bash
tar -xzf openmpi-X.X.X.tar.gz
cd openmpi-X.X.X
```

## Configure the Build:

```bash
./configure --prefix=/path/to/installation --enable-mpi-thread-support
```
Replace `/path/to/installation` with the directory where you want OpenMPI to be installed. The `--enable-mpi-thread-support` option allows for thread-safe MPI calls.

## Compile the Code:

```bash
make -jN
```
Replace `N` with the number of processor cores you want to use for compilation. Using `-j` allows for parallel compilation, speeding up the process.

## Install OpenMPI:

```bash
make install
```
This will install OpenMPI to the specified prefix directory.

## Update Environment Variables:

Add OpenMPI to your `PATH` and `LD_LIBRARY_PATH`. You can do this by adding the following lines to your shell configuration file (e.g., `.bashrc` or `.bash_profile`):

```bash
export PATH=/path/to/installation/bin:$PATH
export LD_LIBRARY_PATH=/path/to/installation/lib:$LD_LIBRARY_PATH
```

Source your configuration file to apply the changes:

```bash
source ~/.bashrc
```

## Install on All Nodes:

Repeat the installation steps on all nodes in your cluster, ensuring that the same version of OpenMPI is installed in the same directory on each node. Alternatively, you can use configuration management tools (like Ansible) to automate the installation process.

## Testing the Installation:

You can verify the installation by running:

```bash
mpirun --version
```

To test the installation, create a simple MPI program and compile it using `mpicc` (the MPI compiler wrapper). Here's a sample program:

```c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    MPI_Init(&argc, &argv);
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    printf("Hello from process %d\n", rank);
    MPI_Finalize();
    return 0;
}
```

Compile the program:

```bash
mpicc -o hello_mpi hello_mpi.c
```

Run the program across multiple processes:

```bash
mpirun -np 4 ./hello_mpi
```
This will run the program on 4 processes, and you should see output from each process.
