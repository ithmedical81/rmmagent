# Tactical RMM Agent for Linux - Installation Package

This package contains the Tactical RMM Agent binaries and installation scripts for Linux systems.

## Package Contents

### Binaries
- `tacticalrmm-linux-amd64` - Agent for 64-bit Intel/AMD systems
- `tacticalrmm-linux-386` - Agent for 32-bit Intel/AMD systems  
- `tacticalrmm-linux-arm64` - Agent for ARM64 systems (Raspberry Pi 4+, etc.)

### Installation Scripts
- `install-linux.sh` - Main installation script
- `uninstall-linux.sh` - Complete removal script
- `configure-linux.sh` - Configuration and management script

### Service Files
- `tacticalagent.service` - SystemD service definition

## Quick Installation

1. **Download and extract** this package to a directory
2. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```
3. **Run installation** (as root):
   ```bash
   sudo ./install-linux.sh
   ```
4. **Configure the agent:**
   ```bash
   sudo ./configure-linux.sh --configure
   ```
5. **Start the service:**
   ```bash
   sudo ./configure-linux.sh --start
   ```

## Supported Linux Distributions

- **Ubuntu** 18.04+ / **Debian** 9+
- **CentOS** 7+ / **RHEL** 7+ / **Rocky Linux** / **AlmaLinux**
- **Fedora** 30+
- Other distributions with SystemD support

## Installation Steps Explained

### 1. Install Dependencies
The installation script will automatically install required packages:
- `curl`, `wget`, `unzip` for downloads
- `systemd` for service management

### 2. Agent Installation
- Creates `/opt/tacticalagent/` directory structure
- Copies the appropriate binary for your architecture
- Sets proper permissions

### 3. Service Configuration
- Creates SystemD service file at `/etc/systemd/system/tacticalagent.service`
- Enables the service to start on boot
- Configures proper security settings

## Configuration

The agent requires configuration before first use:

### Interactive Configuration
```bash
sudo ./configure-linux.sh --configure
```

### Manual Configuration
You can also configure manually by running:
```bash
/opt/tacticalagent/tacticalagent -m install \
    -api "https://api.yourdomain.com" \
    -client-id YOUR_CLIENT_ID \
    -site-id YOUR_SITE_ID \
    -agent-type server \
    -auth "YOUR_AUTH_TOKEN" \
    -desc "$(hostname)"
```

### Required Parameters
- **API URL**: Your Tactical RMM server API endpoint
- **Client ID**: Client identifier from your RMM server
- **Site ID**: Site identifier from your RMM server  
- **Auth Token**: Authentication token from your RMM server
- **Agent Type**: `server` or `workstation`
- **Description**: Human-readable description (optional)

## Service Management

### Using the configure script:
```bash
sudo ./configure-linux.sh --start      # Start service
sudo ./configure-linux.sh --stop       # Stop service
sudo ./configure-linux.sh --restart    # Restart service
sudo ./configure-linux.sh --status     # Check status
```

### Using systemctl directly:
```bash
sudo systemctl start tacticalagent     # Start service
sudo systemctl stop tacticalagent      # Stop service
sudo systemctl restart tacticalagent   # Restart service
sudo systemctl status tacticalagent    # Check status
sudo systemctl enable tacticalagent    # Enable on boot
sudo systemctl disable tacticalagent   # Disable on boot
```

## Logging

View agent logs using journalctl:
```bash
# View recent logs
sudo journalctl -u tacticalagent -n 50

# Follow logs in real-time
sudo journalctl -u tacticalagent -f

# View logs for a specific time period
sudo journalctl -u tacticalagent --since "1 hour ago"
```

## File Locations

- **Agent Binary**: `/opt/tacticalagent/tacticalagent`
- **Configuration**: `/etc/tacticalagent`
- **Service File**: `/etc/systemd/system/tacticalagent.service`
- **Logs**: Use `journalctl -u tacticalagent`

## Troubleshooting

### Agent won't start
1. Check configuration: `sudo ./configure-linux.sh --status`
2. Review logs: `sudo journalctl -u tacticalagent -f`
3. Verify network connectivity to RMM server
4. Check file permissions: `ls -la /opt/tacticalagent/`

### Connection issues
1. Verify API URL is correct and accessible
2. Check firewall settings (agent needs outbound HTTPS access)
3. Verify auth token is valid
4. Test manual connection: `curl -k YOUR_API_URL/api/v3/hello/`

### Permission issues
1. Ensure installation was run as root
2. Check file ownership: `sudo chown -R root:root /opt/tacticalagent/`
3. Verify binary permissions: `sudo chmod +x /opt/tacticalagent/tacticalagent`

## Uninstallation

To completely remove the agent:
```bash
sudo ./uninstall-linux.sh
```

This will:
- Stop and disable the service
- Remove all agent files
- Remove service configuration
- Kill any running processes

## Security Notes

- The agent runs as root (required for system monitoring)
- Service includes security hardening options
- All communication with RMM server uses HTTPS
- Agent authenticates using provided token

## Architecture Detection

The installation script automatically detects your system architecture:
- **x86_64** → uses `tacticalrmm-linux-amd64`
- **i386/i686** → uses `tacticalrmm-linux-386`
- **aarch64/arm64** → uses `tacticalrmm-linux-arm64`

## License

This software is licensed under the Tactical RMM License Version 1.0.
Copyright © 2023 AmidaWare Inc. All rights reserved.

"Tactical RMM" is a trademark of AmidaWare Inc.

## Support

For support and documentation, visit:
- https://docs.tacticalrmm.com/
- https://github.com/amidaware/tacticalrmm

---

**Note**: This agent requires a running Tactical RMM server to connect to. 
Ensure your RMM server is properly configured and accessible before installing the agent.