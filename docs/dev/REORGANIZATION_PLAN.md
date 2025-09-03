# Repository Reorganization Plan

## Current Structure Issues

- Too many files in root directory (31 files)
- Mixed documentation, scripts, and config files
- Some duplicate or outdated files

## Proposed New Structure

```
devpilot/
├── README.md                    # Keep in root (essential)
├── LICENSE                      # Keep in root (essential)
├── VERSION                      # Keep in root (essential)
├── Makefile                     # Keep in root (build file)
├── setup_all.sh                 # Keep in root (main entry point)
│
├── .github/                     # GitHub specific files
│   ├── workflows/               # CI/CD workflows
│   ├── ISSUE_TEMPLATE/          # Issue templates
│   ├── PULL_REQUEST_TEMPLATE/   # PR templates
│   └── documentation-requirements.json
│
├── bin/                         # Executable scripts (unchanged)
│   └── dp                       # Main CLI
│
├── config/                      # Configuration files (NEW)
│   ├── profiles/                # Move from root
│   ├── requirements.txt         # Python deps
│   ├── package.json            # Node deps
│   └── package-lock.json       # Node lock file
│
├── docs/                        # All documentation (expanded)
│   ├── README/                  # Additional readme files
│   │   ├── CHANGELOG.md
│   │   ├── CONTRIBUTING.md
│   │   ├── CODE_OF_CONDUCT.md
│   │   ├── SECURITY.md
│   │   └── RELEASE_NOTES.md
│   ├── guides/                  # User guides
│   │   ├── DOCUMENTATION_REVIEW.md
│   │   ├── REPOSITORY_ACCESS_GUIDE.md
│   │   └── existing guides...
│   ├── dev/                     # Developer docs
│   │   ├── DEVELOPER_CHECKLIST.md
│   │   ├── TESTING_RESULTS.md
│   │   └── TEST_RESULTS.md
│   └── [existing docs]
│
├── install/                     # Installation scripts (unchanged)
├── scripts/                     # Utility scripts (unchanged)
├── setup/                       # Setup scripts (unchanged)
├── system/                      # System files (unchanged)
├── templates/                   # Templates (unchanged)
├── tests/                       # Test files (unchanged)
├── tools/                       # Tools (unchanged)
├── tutorials/                   # Tutorials (unchanged)
├── utils/                       # Utilities (unchanged)
├── validation/                  # Validation scripts (unchanged)
│
├── tmp/                         # Temporary files (NEW)
│   ├── artifacts/              # Move from root
│   ├── downloads/              # Move from root
│   └── .gitkeep
│
└── workspace/                   # Working directories (NEW)
    ├── examples/               # Move from root
    └── devpilot/              # Move from root
```

## Migration Steps

1. Create new directories
2. Move files to new locations
3. Update all script references
4. Update .gitignore
5. Test all functionality
6. Update documentation
