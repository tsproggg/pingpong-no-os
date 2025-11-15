# Environment Setup Guide

- Download CLion to write code conveniently
- Download Docker to run the program
- Download the VNC client to view the program display running in Docker
  - For windows (tested): RealVNC Viewer

- Clone the Git repository using its link in CLion
- Create a configuration in CLion
  - Configuration type: `Docker -> Dockerfile`
  - Configuration parameters:
    - In Run -> Modify -> Bind Ports add following row:
      - Host port: `5900`
      - Container port: `5900`
      - Protocol: `TCP`

- To run the program
  - Run the docker
  - Run the VNC client
  - Run the configuration
  - Connect to the VNC client ONLY after you see that qemu is running in docker logs


- Enjoy!