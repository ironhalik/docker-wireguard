# docker-wireguard

A simple docker image containing everything necessary to run wireguard on your Linux box.

## Why
Most of wireguard docker images build the module (or even install the wireguard package) at run time, inside docker entrypoint. This is not optimal, as restarting or recreating the container causes downtime. This implementation avoids doing so (when it can). 

The wireguard PPA, package, and linux-headers are installed at build time. If the kernel version at build time and run time are the same, then the prebuilt module is installed using `dkms install`, which is almost instant. If the run time kernel differs from the one used to build the module, the entrypoint will install linux-headers and rebuild the module. If this happens, you can always just rebuild (`docker-compose build --no-cache`) the image to update the dependencies, and enjoy fast boot-up times again.

Also, because wireguard needs to install a kernel module on the host, proper clean-up is necessary. When the container is being shut down, the entrypoint _should_ properly delete the network interface and uninstall the kernel module.

## How
- Change the `ubuntu_codename` build arg inside the docker-compose.yml to your host OS ubuntu version (default is `bionic`)
    ```
    sed -i "s/ubuntu_codename=bionic/ubuntu_codename=`lsb_release -cs`/" docker-compose.yml
    ```
- Because the `wg` tools probably ar not available at the host, and you need to generate at least a single key pair to start wireguard, the entrypoint allows you to generate the keys without starting wireguard interface itself. 
    ```
    # docker-compose build
    [...]
    # docker run --rm wireguard:latest gen-key
    Private key: uF9np5jMB6Si+IJ8nrxby1rzdviHeiOUH0/G1GbquGY=
    Public key: yvQxfmovClKxI2hfFTZTAy6zCSWm7dh0Dt3b7sfDG3k=
    ```
    Generate as many keys as needed, and update the example config / create new one. The `./config/` directory will be mounted as `/etc/wireguard/`

- Start the container:
    ```
    # docker-compose up
    ```
## Caveats
- Tested on ubuntu xenial and bionic. Other non-LTS versions will most likely work too, but the base image needs to have a linux-headers package in its repositories that works with with your host OS kernel.
- `NET_ADMIN` and `SYS_MODULE` are required as the container will create network interfaces and routes on the host, and add DKMS kernel modules to the hosts kernel

## Todo's:
- [ ] More intelligent handling of kernel changes.
- [ ] Maybe some wrappers to allow for config hot-reload? (add peers, etc)
- [ ] Get rid of `network_mode: host`?
- [ ] Other base images. Maybe something more universal.

## Acknowledgements
[Activeeos](https://github.com/activeeos) and their [implementation](https://github.com/activeeos/wireguard-docker)

[Stavros Korokithakis](https://www.stavros.io) and his awesome [write up](https://www.stavros.io/posts/how-to-configure-wireguard/)

And of course, [wireguard](https://www.wireguard.com/), for one awesome VPN