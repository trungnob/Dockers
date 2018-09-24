# Quick start (no need to build docker):

  This docker is hosted at hub.docker.com. To do a quick run:

    docker run -p 4113:22 -d nobitut/e310_uhd:latest

This will pull the latest build and run with according options. The option is forwarding port 22 (`sshd`) to an available port on your(host) machine that connected to an E310. `4113` is just an example port.
From E310 shell, do an `sshfs` command :

    root@ettus-e3xx-sg3:~# mkdir ~/localinstall
    root@ettus-e3xx-sg3:~# sshfs root@host.company.com:/e300 ~/localinstall -p 4113

Where password is `e310_docker`
and `host.company.com` is either ip address or fully qualified domain name of the machine that run docker and connected to E310

    root@ettus-e3xx-sg3:~# source ~/localinstall/setupenv.sh
    root@ettus-e3xx-sg3:~# uhd_find_devices
If you done correctly you will see something as this:

```shell
    root@ettus-e3xx-sg3:~# uhd_find_devices
    [INFO] [UHD] linux; GNU C++ version 4.9.2; Boost_105700; UHD_3.14.0.0-0-6af6ac32
    --------------------------------------------------
    -- UHD Device 0
    --------------------------------------------------
    Device Address:
    serial: 30DDB32
    name:
    node: /dev/axi_fpga
    product: E3XX SG3
    type: e3x0
```
# Build instructions:

    docker build -f ./e310_cross_compile.Dockerfile . -t e310_cc:latest

# Run instructions:
    docker run -p 4113:22 -d e310_cc:latest
The above instruction will forward port 22 (`sshd`) to an available port on your(host) machine that connected to an E310. `4113` is just an example port.
From E310 shell, do an `sshfs` command :

    root@ettus-e3xx-sg3:~# mkdir ~/localinstall
    root@ettus-e3xx-sg3:~# sshfs root@host.company.com:/e300 ~/localinstall -p 4113

Where password is `e310_docker`
and `host.company.com` is either ip address or fully qualified domain name of the machine that run docker and connected to E310

    root@ettus-e3xx-sg3:~# source ~/localinstall/setupenv.sh
    root@ettus-e3xx-sg3:~# uhd_find_devices
If you done correctly you will see something as this:

```shell
    root@ettus-e3xx-sg3:~# uhd_find_devices
    [INFO] [UHD] linux; GNU C++ version 4.9.2; Boost_105700; UHD_3.14.0.0-0-6af6ac32
    --------------------------------------------------
    -- UHD Device 0
    --------------------------------------------------
    Device Address:
    serial: 30DDB32
    name:
    node: /dev/axi_fpga
    product: E3XX SG3
    type: e3x0
```
