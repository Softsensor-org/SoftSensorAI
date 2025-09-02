# Repository Access Configuration Guide

## Current Status

- **Repository**: Softsensor-org/DevPilot (Private)
- **Collaborators**: 9 users with mixed access levels
- **Your Role**: Admin

## Recommended Setup for Your Requirements

Since you want everyone in the Softsensor organization to:

1. **Submit issues**
2. **Some have write access** (already configured)
3. **Everyone else has read access**

### Option 1: Quick Setup (Recommended)

Run the access management script and choose option 6:

```bash
./scripts/manage_repo_access.sh
# Choose option 6: Run recommended setup
```

This will:

- Set up team-based access (developers, contributors, admins)
- Add all org members with read access
- Enable issues and discussions

### Option 2: Manual GitHub UI Setup

1. **Go to Repository Settings**:

   ```
   https://github.com/Softsensor-org/DevPilot/settings
   ```

2. **Navigate to "Manage access"**:

   - Click "Invite teams or people"
   - Add the entire "Softsensor-org" organization
   - Set base permission to "Read"

3. **Configure Issue Permissions**:

   - Go to Settings → General
   - Ensure "Issues" is checked
   - Under "Features", enable "Issues"

4. **Set up Teams** (Better long-term):
   - Go to Organization settings
   - Create teams:
     - `developers` - Write access
     - `contributors` - Read access
     - `admins` - Admin access
   - Add repository to each team with appropriate permissions

### Option 3: Using GitHub CLI Commands

```bash
# Enable issues
gh api --method PATCH repos/Softsensor-org/DevPilot \
  -f has_issues=true \
  -f has_discussions=true

# Add all org members with read access
gh api orgs/Softsensor-org/members --jq '.[].login' | while read member; do
  gh api --method PUT repos/Softsensor-org/DevPilot/collaborators/$member \
    -f permission="pull"
done

# Create and configure teams
gh api --method POST orgs/Softsensor-org/teams \
  -f name="developers" \
  -f description="Core development team" \
  -f privacy="closed"

gh api --method PUT orgs/Softsensor-org/teams/developers/repos/Softsensor-org/DevPilot \
  -f permission="push"
```

## Important Notes

### For Private Repositories

- **Issue Creation**: Only organization members and collaborators can create issues
- **External Contributors**: Cannot create issues unless given explicit access
- **Visibility**: Code is only visible to those with access

### Current Access Levels

| User            | Access Level | Can Do                        |
| --------------- | ------------ | ----------------------------- |
| Admin (6 users) | Full control | Everything including settings |
| Write (1 user)  | Push access  | Create branches, merge PRs    |
| Read (1 user)   | View only    | View code, create issues      |

### If You Want Public Issues

If you want ANYONE (including external users) to submit issues, you need to:

1. **Make the repository public**:

   ```bash
   gh api --method PATCH repos/Softsensor-org/DevPilot -f private=false
   ```

2. **Or keep it private** and individually invite external contributors

## Best Practices

1. **Use Teams**: More maintainable than individual permissions
2. **Document Access**: Keep a record of who has what access
3. **Regular Audits**: Review access quarterly
4. **Minimal Permissions**: Give only necessary access levels

## Quick Commands

```bash
# View current access
./scripts/manage_repo_access.sh
# Choose option 1

# Add all org members
./scripts/manage_repo_access.sh
# Choose option 3

# Full recommended setup
./scripts/manage_repo_access.sh
# Choose option 6
```

## Next Steps

1. Run `./scripts/manage_repo_access.sh` and choose option 6
2. Verify all organization members can now create issues
3. Document any special access requirements
4. Consider making repo public when ready for external contributions
