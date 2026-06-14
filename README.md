# PING-PONG NO OS

## Team Members
<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Menuas">
        <img src="https://avatars.githubusercontent.com/Menuas?v=4" width="75px;" alt=""/>
      </a>
      <br />
      <sub><b><a href="https://github.com/Menuas" style="text-decoration: none !important; color: inherit;">Menua Simonian</a></b></sub>
    </td>
    <td align="center">
      <a href="https://github.com/tsproggg">
        <img src="https://avatars.githubusercontent.com/tsproggg?v=4" width="75px;" alt=""/>
      </a>
      <br />
      <sub><b><a href="https://github.com/tsproggg" style="text-decoration: none !important; color: inherit;">Valerii Sofian</a></b></sub>
    </td>
    <td align="center">
      <a href="https://github.com/0x3vAD">
        <img src="https://avatars.githubusercontent.com/0x3vAD?v=4" width="75px;" alt=""/>
      </a>
      <br />
      <sub><b><a href="https://github.com/0x3vAD" style="text-decoration: none !important; color: inherit;">Davit Ter-Torosyan</a></b></sub>
    </td>
  </tr>
</table>


## About Project

This project was developed as part of the Computer Organisation course at the American University of Armenia under the supervision of Professor [Norayr Chilingaryan](https://github.com/norayr), whose guidance and teaching were invaluable throughout the project.

It is a simple implementation of the classic Ping-Pong game that runs without an operating system. The game is written entirely in assembly language, uses BIOS interrupts and VGA text mode for input and display, and executes directly on bare metal hardware. It is designed for two players using a keyboard

## How to Run

### Running on Unix-like Systems
If you have installed [qemu-system-i386](https://www.qemu.org/) on your machine, and you are on a Unix-like system, you can simply compile with the make file. The make file will compile the assembly code and create a bootable image file, which can be run using qemu.

```bash
make all
```

### Running using Docker
If you don't have installed qemu, or you are using Windows, you can use Docker to run the game. 

```bash
docker build -t ping-pong-no-os .
docker run -p 5900:5900 ping-pong-no-os
```

After running the the both cases, you can connect to the game using a VNC client. The default VNC port is 5900. You can use any VNC client of your choice to connect to the game, but we only tested it with [TigerVNC](https://tigervnc.org/) and [RealVNC Viewer](https://www.realvnc.com/en).

## Small Demo

https://github.com/user-attachments/assets/f8dcfaa0-275b-49f9-837d-59792a406737
