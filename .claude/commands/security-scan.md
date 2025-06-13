# Security Scan

Perform security vulnerability assessment and identify potential security issues.

## Arguments

- `$1` (depth): "quick", "standard", "thorough" (default: "standard")
- `$2` (include_deps): "true", "false" (default: "true")

## Usage

```bash
/security-scan
/security-scan thorough true
/security-scan quick false
/security-scan standard true
```

## Prompt

Perform security scan with depth: $1
Include dependency vulnerabilities: $2

Check for:
- Common security vulnerabilities
- Insecure coding patterns
- Exposed sensitive information
- Input validation problems
- File system access vulnerabilities
- Network communication security
- Authentication/authorization issues (if applicable)
- Data handling and storage security

For this Godot project, specifically analyze:

**Code Security:**
- GDScript input validation and sanitization
- File path traversal vulnerabilities
- Resource loading security (scenes, scripts, assets)
- Network communication security (HTTP/HTTPS)
- User data handling and storage
- Configuration file security
- Error message information disclosure

**Asset Security:**
- Embedded sensitive data in assets
- Asset file permissions and access
- Dynamic content loading security
- External asset source validation
- Asset integrity and verification

**Build and Distribution Security:**
- Export template security
- Build process vulnerability analysis
- Platform-specific security considerations
- Code obfuscation and protection
- Digital signing and verification

**Runtime Security:**
- Memory safety and buffer overflows
- Script injection vulnerabilities
- Resource exhaustion attacks
- Privilege escalation risks
- Sandbox escape vulnerabilities

**Dependency Security:**
- Third-party addon/plugin vulnerabilities
- External library security issues
- Asset pipeline security
- Development tool vulnerabilities

Provide prioritized remediation steps:
- Critical security issues (immediate attention)
- High-risk vulnerabilities (next release)
- Medium-risk issues (planned updates)
- Low-risk improvements (future enhancements)

Include:
- Vulnerability descriptions and impact
- Exploitation scenarios and examples
- Specific remediation instructions
- Best practice recommendations
- Security testing procedures
- Monitoring and detection strategies

Focus on security measures for:
- User data protection
- Game state integrity
- Network communication
- File system access
- Plugin/addon security
- Platform-specific vulnerabilities
