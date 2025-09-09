#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';

// Colors for output
const colors = {
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

// Extract commands from bin/dp
async function extractCommands() {
  const dpPath = path.join(process.cwd(), 'bin', 'dp');
  
  try {
    const content = await fs.readFile(dpPath, 'utf-8');
    
    // Find all cmd_* function definitions
    const cmdFunctions = content.match(/^cmd_[a-z_]+\(\)/gm) || [];
    const functionCommands = cmdFunctions.map(fn => 
      fn.replace('cmd_', '').replace('()', '').replace(/_/g, '-')
    );
    
    // Find all case statement commands
    const caseMatches = content.match(/^\s+([a-z-]+)\)\s*shift;\s*cmd_/gm) || [];
    const caseCommands = caseMatches.map(match => {
      const cmd = match.trim().split(')')[0];
      return cmd;
    });
    
    // Combine and deduplicate
    const allCommands = [...new Set([...functionCommands, ...caseCommands])];
    
    // Filter out special cases and non-commands
    const validCommands = allCommands.filter(cmd => {
      // Skip empty, help flags, and internal functions
      if (!cmd || cmd === '-h' || cmd === '--help' || cmd === '') return false;
      // Skip if it's just whitespace
      if (cmd.trim() === '') return false;
      // Keep valid command names
      return /^[a-z][a-z-]*$/.test(cmd);
    });
    
    return validCommands.sort();
  } catch (error) {
    console.error(`${colors.red}Failed to read bin/dp: ${error.message}${colors.reset}`);
    return [];
  }
}

// Extract documented commands from docs/commands/
async function extractDocumentedCommands() {
  const docsDir = path.join(process.cwd(), 'docs', 'commands', 'dp');
  
  try {
    // Check if directory exists
    await fs.access(docsDir);
    
    // List all .md files
    const files = await fs.readdir(docsDir);
    const mdFiles = files.filter(f => f.endsWith('.md'));
    
    // Convert filenames to command names
    const commands = mdFiles.map(f => f.replace('.md', ''));
    
    return commands.sort();
  } catch (error) {
    console.error(`${colors.yellow}Warning: docs/commands/dp directory not found${colors.reset}`);
    return [];
  }
}

// Compare command lists and find differences
function compareCommands(implemented, documented) {
  const implementedSet = new Set(implemented);
  const documentedSet = new Set(documented);
  
  // Find commands that are implemented but not documented
  const undocumented = implemented.filter(cmd => !documentedSet.has(cmd));
  
  // Find commands that are documented but not implemented
  const unimplemented = documented.filter(cmd => !implementedSet.has(cmd));
  
  return { undocumented, unimplemented };
}

// Main parity check
async function checkParity() {
  console.log(`${colors.blue}📋 Command/Documentation Parity Check${colors.reset}\n`);
  
  // Extract commands from both sources
  const implemented = await extractCommands();
  const documented = await extractDocumentedCommands();
  
  console.log(`Found ${implemented.length} implemented commands`);
  console.log(`Found ${documented.length} documented commands\n`);
  
  // Compare
  const { undocumented, unimplemented } = compareCommands(implemented, documented);
  
  let hasErrors = false;
  
  // Report undocumented commands
  if (undocumented.length > 0) {
    hasErrors = true;
    console.log(`${colors.red}❌ Undocumented commands (${undocumented.length}):${colors.reset}`);
    undocumented.forEach(cmd => {
      console.log(`   - ${cmd} (missing docs/commands/dp/${cmd}.md)`);
    });
    console.log();
  }
  
  // Report unimplemented commands
  if (unimplemented.length > 0) {
    hasErrors = true;
    console.log(`${colors.red}❌ Documented but not implemented (${unimplemented.length}):${colors.reset}`);
    unimplemented.forEach(cmd => {
      console.log(`   - ${cmd} (docs exist but command not in bin/dp)`);
    });
    console.log();
  }
  
  // Summary
  if (hasErrors) {
    console.log(`${colors.red}❌ Parity check failed${colors.reset}`);
    console.log('\nTo fix:');
    
    if (undocumented.length > 0) {
      console.log('1. Create documentation for undocumented commands:');
      undocumented.forEach(cmd => {
        console.log(`   touch docs/commands/dp/${cmd}.md`);
      });
    }
    
    if (unimplemented.length > 0) {
      console.log('2. Remove documentation for unimplemented commands or implement them:');
      unimplemented.forEach(cmd => {
        console.log(`   rm docs/commands/dp/${cmd}.md  # or implement the command`);
      });
    }
    
    process.exit(1);
  } else {
    console.log(`${colors.green}✅ All commands properly documented${colors.reset}`);
    console.log('\nImplemented and documented commands:');
    implemented.forEach(cmd => {
      console.log(`   ✓ ${cmd}`);
    });
  }
}

// Show detailed report if requested
async function detailedReport() {
  const implemented = await extractCommands();
  const documented = await extractDocumentedCommands();
  
  console.log(`\n${colors.blue}Detailed Command Report${colors.reset}`);
  console.log('━'.repeat(50));
  
  console.log('\n📝 Implemented Commands:');
  implemented.forEach(cmd => console.log(`   - ${cmd}`));
  
  console.log('\n📚 Documented Commands:');
  documented.forEach(cmd => console.log(`   - ${cmd}`));
  
  // Check for help text in each command
  console.log('\n🔍 Command Help Availability:');
  for (const cmd of implemented) {
    try {
      // Try to get help for command
      const helpOutput = execSync(`bin/dp ${cmd} --help 2>&1`, { 
        encoding: 'utf-8',
        stdio: 'pipe'
      });
      
      if (helpOutput.includes('unknown subcommand') || helpOutput.includes('error')) {
        console.log(`   ⚠️  ${cmd}: No help available`);
      } else {
        console.log(`   ✓ ${cmd}: Has help text`);
      }
    } catch {
      console.log(`   ⚠️  ${cmd}: Help check failed`);
    }
  }
}

// Run checks
const args = process.argv.slice(2);

if (args.includes('--detailed') || args.includes('-d')) {
  detailedReport().catch(error => {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  });
} else {
  checkParity().catch(error => {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  });
}