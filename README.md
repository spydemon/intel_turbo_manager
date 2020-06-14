# Intel Turbo Manager

Switch on or off the turbo mode of your CPU depending on the current fan speed.
The purpose of this script is to find a compromise between performance and noise or power consumption.

This script only works for Intel CPUs that handle this mode.

## How to use it

### Clone of the repository

The first step is to clone it, for example in the `/opt/intel_turbo_manager` folder :

```txt
git clone <repository> /opt/intel_turbo_manager
```

### Configuration of the script

Next step is to read the provided `intel_turbo_manager.default.yml` file and to check that default parameter values fit your needs. If it's not the case, create a new `intel_turbo_manager.yml` and override the problematic ones.

The default configuration should look like the following:

```yaml
# This is the default configuration file used by the intel_turbo_manager.pl script.
# Do not edit it, but create a new one named "intel_turbo_manager.pl" with your modification instead.

[control]

# JSON path that identifies the location of the fan speed to monitor.
# You can find it by running the `sensors -j` command.
fan_path = dell_smm-virtual-0/fan1/fan1_input

# Speed in RPM that defines the limit after which the turbo mode should be disabled.
# When the speed of the fan goes down of the limit, the turbo mode is switched on again.
fan_limit = 4500
```

### Installation of the systemd service

The script can easily be launched by hand, but it could be more convenient to let systemd deals with it. In this second case, the first step is to create a symbolic link between the provided service file and the localization where systemd expect to find them:

```text
ln -s /opt/intel_turbo_manager/systemd/intel_turbo_manager.target /etc/systemd/system
```

And now, to enable the service:

```text
systemctl enable intel_turbo_manager
```

Now, the script should run directly at the startup of your computer.

## Inspiration

Thanks Chris for having written the [Manage Intel Turbo Boost with systemd](https://blog.christophersmart.com/2017/02/08/manage-intel-turbo-boost-with-systemd/) article on its blog. It way a good inspiration for me.

## Help Appreciated

If you like this script and find a bug or an enhancement, don't hesitate to fill an issue, or even better: a pull request. 😀
