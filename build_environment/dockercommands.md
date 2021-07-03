___ Build ___
docker build build_environment -t kernel_build_environment

___ Run ___
Windows: docker run --rm -it -v /%cd%:/root/env kernel_build_environment ***command prompt***
         docker run --rm -it -v "${pwd}:/root/env" build_environment_kernel ***powershell (VS Code terminal)***

Linux/Mac: docker run --rm -it -v /$pwd:/root/env kernel_build_environment

___ Kernel Build ___
make buildx86_64