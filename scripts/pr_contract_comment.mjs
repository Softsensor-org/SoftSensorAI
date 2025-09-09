#!/usr/bin/env node
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { createHash } from 'crypto';
import matter from 'gray-matter';

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const PR_NUMBER = process.env.PR_NUMBER;
const BASE_SHA = process.env.BASE_SHA || 'HEAD~1';
const HEAD_SHA = process.env.HEAD_SHA || 'HEAD';
const COMMENT_ANCHOR = '<!-- CONTRACT_SUMMARY -->';

// Get repo info from git remote
function getRepoInfo() {
  const remote = execSync('git remote get-url origin', { encoding: 'utf8' }).trim();
  const match = remote.match(/github\.com[:/]([^/]+)\/([^.]+)/);
  if (!match) throw new Error('Could not parse GitHub repo from remote');
  return { owner: match[1], repo: match[2].replace('.git', '') };
}

// Parse contract IDs from commit or PR body
function parseContractIds() {
  const ids = new Set();
  
  // Check for environment variable first (for testing)
  if (process.env.CONTRACT_IDS) {
    process.env.CONTRACT_IDS.split(',').forEach(id => ids.add(id.trim()));
    return Array.from(ids);
  }
  
  // Try commit trailers first
  try {
    const message = execSync(`git log -1 --format=%B ${HEAD_SHA}`, { encoding: 'utf8' });
    const trailerMatch = message.match(/^Contract-Id:\s*(.+)$/mi);
    if (trailerMatch) {
      trailerMatch[1].split(',').forEach(id => ids.add(id.trim()));
    }
  } catch {}
  
  // Fallback to PR body if available
  if (ids.size === 0 && PR_NUMBER) {
    try {
      const { owner, repo } = getRepoInfo();
      const pr = JSON.parse(execSync(
        `gh api repos/${owner}/${repo}/pulls/${PR_NUMBER}`,
        { encoding: 'utf8' }
      ));
      const bodyMatch = pr.body?.match(/Contract-Id:\s*(.+)/i);
      if (bodyMatch) {
        bodyMatch[1].split(',').forEach(id => ids.add(id.trim()));
      }
    } catch {}
  }
  
  return Array.from(ids);
}

// Get contract scope and hash using existing script
function getContractScope(contractIds) {
  if (contractIds.length === 0) return {};
  
  const result = {};
  
  // Run scope check for each contract individually
  contractIds.forEach(id => {
    try {
      // Get changed files
      const changedFiles = execSync(`git diff --name-only ${BASE_SHA}...${HEAD_SHA}`, { encoding: 'utf8' })
        .trim()
        .split('\n')
        .filter(Boolean);
      
      // Read contract to get patterns
      const contract = readContract(id);
      if (!contract) return;
      
      const inScope = [];
      const outOfScope = [];
      const testFiles = [];
      
      // Check each file against patterns
      changedFiles.forEach(file => {
        let isAllowed = false;
        let isForbidden = false;
        
        // Check allowed patterns
        if (contract.allowed_globs) {
          contract.allowed_globs.forEach(pattern => {
            if (matchPattern(file, pattern)) {
              isAllowed = true;
            }
          });
        }
        
        // Check forbidden patterns
        if (contract.forbidden_globs) {
          contract.forbidden_globs.forEach(pattern => {
            if (matchPattern(file, pattern)) {
              isForbidden = true;
            }
          });
        }
        
        // Categorize file
        if (isForbidden) {
          outOfScope.push(file);
        } else if (isAllowed) {
          inScope.push(file);
          if (file.includes('test')) {
            testFiles.push(file);
          }
        } else if (!contract.allowed_globs || contract.allowed_globs.length === 0) {
          // If no allowed patterns specified, everything not forbidden is in scope
          inScope.push(file);
          if (file.includes('test')) {
            testFiles.push(file);
          }
        } else {
          outOfScope.push(file);
        }
      });
      
      // Calculate simple hash from contract content
      const contractPath = path.join('contracts', `${id}.contract.md`);
      if (fs.existsSync(contractPath)) {
        const content = fs.readFileSync(contractPath, 'utf8');
        const hash = createHash('sha256').update(content).digest('hex');
        
        result[id] = {
          hash: hash.substring(0, 8),
          inScope,
          outOfScope,
          testFiles
        };
      } else {
        result[id] = {
          hash: 'N/A',
          inScope,
          outOfScope,
          testFiles
        };
      }
    } catch (err) {
      console.error(`Error processing contract ${id}:`, err.message);
    }
  });
  
  return result;
}

// Helper function to match glob patterns
function matchPattern(file, pattern) {
  // Convert glob to regex-like pattern
  if (pattern.endsWith('**')) {
    const prefix = pattern.slice(0, -2);
    return file.startsWith(prefix);
  } else if (pattern.includes('*')) {
    // Simple wildcard matching
    const regex = new RegExp('^' + pattern.replace(/\*/g, '.*') + '$');
    return regex.test(file);
  } else {
    return file === pattern;
  }
}

// Read contract metadata
function readContract(id) {
  const contractPath = path.join('contracts', `${id}.contract.md`);
  if (!fs.existsSync(contractPath)) return null;
  
  const content = fs.readFileSync(contractPath, 'utf8');
  const { data, content: body } = matter(content);
  
  // Parse criteria from YAML frontmatter
  const criteria = [];
  if (data.acceptance_criteria) {
    data.acceptance_criteria.forEach(criterion => {
      criteria.push({
        id: criterion.id,
        required: criterion.must?.startsWith('MUST') || false,
        text: criterion.text,
        tests: criterion.tests || []
      });
    });
  }
  
  return { ...data, criteria };
}

// Build markdown comment
function buildComment(contractIds, scopeData) {
  const lines = [COMMENT_ANCHOR];
  lines.push('## 📋 Contract Summary\n');
  
  // Contracts table
  lines.push('### Contracts Referenced');
  lines.push('| Contract | Hash | Status | Owner |');
  lines.push('|----------|------|--------|-------|');
  
  contractIds.forEach(id => {
    const contract = readContract(id);
    const scope = scopeData[id] || {};
    
    if (contract) {
      const hash = scope.hash || 'N/A';
      const status = contract.status || 'draft';
      const owner = contract.owner || 'unassigned';
      lines.push(`| **${id}** | \`${hash}\` | ${status} | @${owner} |`);
    }
  });
  
  lines.push('');
  
  // Criteria mapping
  lines.push('### Acceptance Criteria');
  lines.push('| Contract | ID | Required | Description | Tests |');
  lines.push('|----------|-----|----------|-------------|-------|');
  
  contractIds.forEach(id => {
    const contract = readContract(id);
    const scope = scopeData[id] || {};
    
    if (contract?.criteria) {
      contract.criteria.forEach(criterion => {
        // Check if any of the specified test files exist in the changed files
        const hasTests = criterion.tests.length > 0 && criterion.tests.some(testFile => {
          return scope.inScope?.includes(testFile) || 
                 fs.existsSync(path.join(process.cwd(), testFile));
        });
        const testIcon = hasTests ? '✅' : '❌';
        const reqIcon = criterion.required ? '🔴' : '⚪';
        lines.push(`| ${id} | ${criterion.id} | ${reqIcon} | ${criterion.text} | ${testIcon} |`);
      });
    }
  });
  
  lines.push('');
  
  // Changed files by contract
  lines.push('### Changed Files');
  
  const allChangedFiles = new Set();
  try {
    const diff = execSync(`git diff --name-only ${BASE_SHA}...${HEAD_SHA}`, { encoding: 'utf8' });
    diff.trim().split('\n').forEach(f => allChangedFiles.add(f));
  } catch {}
  
  contractIds.forEach(id => {
    const scope = scopeData[id] || {};
    lines.push(`\n#### ${id}`);
    
    if (scope.inScope?.length > 0) {
      lines.push('**In Scope:**');
      scope.inScope.forEach(f => lines.push(`- ✅ ${f}`));
    }
    
    if (scope.outOfScope?.length > 0) {
      lines.push('**Out of Scope:** ⚠️');
      scope.outOfScope.forEach(f => lines.push(`- ❌ ${f}`));
    }
  });
  
  // Telemetry events
  lines.push('\n### Telemetry Events');
  let hasEvents = false;
  contractIds.forEach(id => {
    const contract = readContract(id);
    if (contract?.telemetry?.events && contract.telemetry.events.length > 0) {
      hasEvents = true;
      lines.push(`**${id}:**`);
      contract.telemetry.events.forEach(event => {
        // Events can be strings or objects
        if (typeof event === 'string') {
          lines.push(`- \`${event}\``);
        } else if (event?.name) {
          lines.push(`- \`${event.name}\`: ${event.description || 'No description'}`);
        }
      });
    }
  });
  if (!hasEvents) {
    lines.push('*No telemetry events declared*');
  }
  
  // Performance budgets
  lines.push('\n### Performance Budgets');
  let hasBudgets = false;
  contractIds.forEach(id => {
    const contract = readContract(id);
    if (contract?.budgets) {
      hasBudgets = true;
      lines.push(`**${id}:**`);
      // Handle different budget formats
      if (contract.budgets.latency_ms_p50) {
        lines.push(`- Latency P50: ${contract.budgets.latency_ms_p50}ms`);
      }
      if (contract.budgets.latency_ms_p99) {
        lines.push(`- Latency P99: ${contract.budgets.latency_ms_p99}ms`);
      }
      if (contract.budgets.bundle_kb_delta_max) {
        lines.push(`- Bundle Size Delta: max ${contract.budgets.bundle_kb_delta_max}kb increase`);
      }
      // Also handle nested format
      if (contract.budgets.latency) {
        lines.push(`- Latency: p50=${contract.budgets.latency.p50}ms, p99=${contract.budgets.latency.p99}ms`);
      }
      if (contract.budgets.bundle) {
        lines.push(`- Bundle: main=${contract.budgets.bundle.main}kb, vendor=${contract.budgets.bundle.vendor}kb`);
      }
    }
  });
  if (!hasBudgets) {
    lines.push('*No performance budgets declared*');
  }
  
  return lines.join('\n');
}

// Post or update comment
async function postComment(comment) {
  if (!GITHUB_TOKEN || !PR_NUMBER) {
    console.log('No GitHub token or PR number, printing comment:');
    console.log(comment);
    return;
  }
  
  const { owner, repo } = getRepoInfo();
  
  // Find existing comment
  const comments = JSON.parse(execSync(
    `gh api repos/${owner}/${repo}/issues/${PR_NUMBER}/comments`,
    { encoding: 'utf8' }
  ));
  
  const existing = comments.find(c => c.body?.includes(COMMENT_ANCHOR));
  
  if (existing) {
    // Update existing comment using stdin to avoid shell escaping issues
    execSync(
      `gh api repos/${owner}/${repo}/issues/comments/${existing.id} -X PATCH --field body=@-`,
      { input: comment, encoding: 'utf8' }
    );
    console.log(`Updated comment ${existing.id}`);
  } else {
    // Create new comment using stdin to avoid shell escaping issues
    execSync(
      `gh api repos/${owner}/${repo}/issues/${PR_NUMBER}/comments --field body=@-`,
      { input: comment, encoding: 'utf8' }
    );
    console.log('Created new comment');
  }
}

// Main
const contractIds = parseContractIds();
if (contractIds.length === 0) {
  console.log('No contract IDs found in commit trailers or PR body');
  process.exit(0);
}
const scopeData = getContractScope(contractIds);
const comment = buildComment(contractIds, scopeData);
await postComment(comment);