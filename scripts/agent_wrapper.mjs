#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import { minimatch } from 'minimatch';

const ACTIVE_TASK_PATH = '.softsensor/active-task.json';
const ARTIFACTS_DIR = 'artifacts';

// Colors for output
const colors = {
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  reset: '\x1b[0m'
};

// Load active task configuration
async function loadActiveTask() {
  try {
    const content = await fs.readFile(ACTIVE_TASK_PATH, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`${colors.red}❌ No active task found${colors.reset}`);
    console.error('   Create .softsensor/active-task.json with contract_id');
    return null;
  }
}

// Load contract file
async function loadContract(contractId) {
  try {
    const contractPath = path.join('contracts', `${contractId}.contract.md`);
    const content = await fs.readFile(contractPath, 'utf-8');
    return content;
  } catch (error) {
    console.error(`${colors.red}❌ Contract not found: ${contractId}${colors.reset}`);
    return null;
  }
}

// Parse contract for metadata
function parseContract(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;
  
  const yaml = match[1];
  const body = content.substring(match[0].length);
  
  // Extract key fields
  const id = yaml.match(/^id:\s*(.+)$/m)?.[1];
  const title = yaml.match(/^title:\s*(.+)$/m)?.[1];
  
  // Extract acceptance criteria
  const criteriaMatch = yaml.match(/acceptance_criteria:\s*\n([\s\S]*?)(?=\n[^\s]|\n*$)/);
  let criteria = [];
  
  if (criteriaMatch) {
    const criteriaText = criteriaMatch[1];
    const criteriaItems = criteriaText.split(/\n\s*-\s+id:/).filter(Boolean);
    
    for (const item of criteriaItems) {
      const id = item.match(/^\s*(.+?)$/m)?.[1] || '';
      const must = item.match(/must:\s*(.+)$/m)?.[1] || '';
      const text = item.match(/text:\s*(.+)$/m)?.[1] || '';
      
      if (id) {
        criteria.push({
          id: id.startsWith('id:') ? id.substring(3).trim() : id.trim(),
          must,
          text
        });
      }
    }
  }
  
  return { id, title, criteria, body };
}

// Build agent prompt
function buildPrompt(task, contract, goal) {
  const systemPrompt = `You are an AI agent bound by a contract-driven development system.

CRITICAL RULES:
1. You MUST NOT modify any files outside the allowed_globs patterns
2. You MUST respect all forbidden_globs patterns
3. You MUST output your response in EXACTLY three sections: PLAN, PATCH, and DIFF SUMMARY
4. Each section MUST be clearly marked with ## headers

Allowed globs for this task:
${task.allowed_globs.map(g => `  - ${g}`).join('\n')}

Forbidden globs (NEVER touch these):
${task.forbidden_globs.map(g => `  - ${g}`).join('\n')}

Output Format Requirements:
1. ## PLAN - Describe your approach in bullet points
2. ## PATCH - Provide unified diff format patches for file changes
3. ## DIFF SUMMARY - Summarize changes in a structured format`;

  const userPrompt = `Contract: ${contract.id} - ${contract.title}

Acceptance Criteria:
${contract.criteria.map(c => `- ${c.id}: ${c.must}\n  ${c.text}`).join('\n')}

Task Goal: ${goal}

Contract Context:
${contract.body.substring(0, 1000)}...

Please complete this task following the contract constraints and output format.`;

  return { systemPrompt, userPrompt };
}

// Extract files from patch section
function extractFilesFromPatch(patchText) {
  const files = new Set();
  const lines = patchText.split('\n');
  
  for (const line of lines) {
    // Look for diff headers
    if (line.startsWith('--- ') || line.startsWith('+++ ')) {
      const match = line.match(/^[\-+]{3}\s+([^\s\t]+)/);
      if (match && match[1] !== '/dev/null') {
        // Remove a/ b/ prefixes
        const file = match[1].replace(/^[ab]\//, '');
        files.add(file);
      }
    }
    // Also look for simple file references
    else if (line.match(/^(File:|Modified:|Created:|Deleted:)\s+(.+)$/)) {
      const match = line.match(/^(?:File:|Modified:|Created:|Deleted:)\s+(.+)$/);
      if (match) {
        files.add(match[1].trim());
      }
    }
  }
  
  return Array.from(files);
}

// Validate files against globs
function validateFiles(files, allowedGlobs, forbiddenGlobs) {
  const violations = [];
  
  for (const file of files) {
    // Check forbidden first
    if (forbiddenGlobs.some(glob => minimatch(file, glob))) {
      violations.push(`❌ Forbidden: ${file}`);
      continue;
    }
    
    // Check allowed
    if (allowedGlobs.length > 0 && !allowedGlobs.some(glob => minimatch(file, glob))) {
      violations.push(`⚠️  Out of scope: ${file}`);
    }
  }
  
  return violations;
}

// Parse model output into sections
function parseModelOutput(output) {
  const sections = {
    plan: '',
    patch: '',
    summary: ''
  };
  
  // Try to find sections with ## headers
  const planMatch = output.match(/##\s*PLAN\s*\n([\s\S]*?)(?=##\s*PATCH|$)/i);
  const patchMatch = output.match(/##\s*PATCH\s*\n([\s\S]*?)(?=##\s*DIFF\s*SUMMARY|$)/i);
  const summaryMatch = output.match(/##\s*DIFF\s*SUMMARY\s*\n([\s\S]*?)$/i);
  
  if (planMatch) sections.plan = planMatch[1].trim();
  if (patchMatch) sections.patch = patchMatch[1].trim();
  if (summaryMatch) sections.summary = summaryMatch[1].trim();
  
  // Validate all sections exist
  const missing = [];
  if (!sections.plan) missing.push('PLAN');
  if (!sections.patch) missing.push('PATCH');
  if (!sections.summary) missing.push('DIFF SUMMARY');
  
  if (missing.length > 0) {
    return { valid: false, missing, sections };
  }
  
  return { valid: true, sections };
}

// Call AI model via shim
async function callAI(systemPrompt, userPrompt) {
  const shimPath = path.join(path.dirname(process.argv[1]), '..', 'tools', 'ai_shim.sh');
  
  // Create temp prompt file
  const promptFile = path.join(ARTIFACTS_DIR, 'agent_prompt.txt');
  await fs.mkdir(ARTIFACTS_DIR, { recursive: true });
  
  const fullPrompt = `${systemPrompt}\n\n---\n\n${userPrompt}`;
  await fs.writeFile(promptFile, fullPrompt);
  
  console.log(`${colors.blue}🤖 Calling AI agent...${colors.reset}`);
  
  // Try different providers
  const providers = ['claude', 'codex', 'gemini', 'grok'];
  let output = '';
  
  for (const provider of providers) {
    try {
      const model = process.env[`AI_MODEL_${provider.toUpperCase()}`] || `${provider}-latest`;
      output = execSync(
        `"${shimPath}" --provider ${provider} --model "${model}" --prompt-file "${promptFile}"`,
        { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }
      );
      
      if (output.trim()) {
        console.log(`${colors.green}✅ Got response from ${provider}${colors.reset}`);
        break;
      }
    } catch (error) {
      // Try next provider
      continue;
    }
  }
  
  if (!output.trim()) {
    throw new Error('No AI provider returned output');
  }
  
  // Save output
  const outputFile = path.join(ARTIFACTS_DIR, 'agent_output.txt');
  await fs.writeFile(outputFile, output);
  
  return output;
}

async function main() {
  const goal = process.argv.slice(2).join(' ');
  
  if (!goal) {
    console.error(`${colors.red}❌ Please provide a task goal${colors.reset}`);
    console.log('Usage: npm run agent:task "implement feature X"');
    process.exit(1);
  }
  
  console.log(`${colors.cyan}📋 Agent Task Runner${colors.reset}`);
  console.log(`   Goal: ${goal}`);
  
  // Load active task
  const activeTask = await loadActiveTask();
  if (!activeTask || !activeTask.contract_id) {
    process.exit(1);
  }
  
  console.log(`   Contract: ${activeTask.contract_id}`);
  
  // Load contract
  const contractContent = await loadContract(activeTask.contract_id);
  if (!contractContent) {
    process.exit(1);
  }
  
  const contract = parseContract(contractContent);
  if (!contract) {
    console.error(`${colors.red}❌ Failed to parse contract${colors.reset}`);
    process.exit(1);
  }
  
  // Merge globs from task and contract
  const allowedGlobs = [...new Set([
    ...(activeTask.allowed_globs || []),
    ...(contract.allowed_globs || [])
  ])];
  const forbiddenGlobs = [...new Set([
    ...(activeTask.forbidden_globs || []),
    ...(contract.forbidden_globs || [])
  ])];
  
  // Build prompt
  const { systemPrompt, userPrompt } = buildPrompt(
    { allowed_globs: allowedGlobs, forbidden_globs: forbiddenGlobs },
    contract,
    goal
  );
  
  // Call AI
  let output;
  try {
    output = await callAI(systemPrompt, userPrompt);
  } catch (error) {
    console.error(`${colors.red}❌ Failed to get AI response: ${error.message}${colors.reset}`);
    process.exit(1);
  }
  
  // Parse output
  const parsed = parseModelOutput(output);
  
  if (!parsed.valid) {
    console.error(`${colors.red}❌ Invalid output format${colors.reset}`);
    console.error(`   Missing sections: ${parsed.missing.join(', ')}`);
    console.error('   The model must output: ## PLAN, ## PATCH, ## DIFF SUMMARY');
    
    // Save for debugging
    const debugFile = path.join(ARTIFACTS_DIR, 'agent_invalid_output.txt');
    await fs.writeFile(debugFile, output);
    console.error(`   Output saved to: ${debugFile}`);
    process.exit(1);
  }
  
  // Extract and validate files from patch
  const files = extractFilesFromPatch(parsed.sections.patch);
  console.log(`\n${colors.blue}📁 Files in patch: ${files.length}${colors.reset}`);
  
  if (files.length > 0) {
    const violations = validateFiles(files, allowedGlobs, forbiddenGlobs);
    
    if (violations.length > 0) {
      console.error(`\n${colors.red}❌ Contract violations detected:${colors.reset}`);
      violations.forEach(v => console.error(`   ${v}`));
      console.error('\nThe agent attempted to modify files outside the contract scope.');
      console.error('This is not allowed. Please adjust the task or contract.');
      
      // Save for debugging
      const violationFile = path.join(ARTIFACTS_DIR, 'agent_violations.txt');
      await fs.writeFile(violationFile, violations.join('\n') + '\n\n' + output);
      console.error(`   Details saved to: ${violationFile}`);
      process.exit(1);
    }
    
    console.log(`${colors.green}✅ All files within contract scope${colors.reset}`);
  }
  
  // Output the validated response
  console.log(`\n${colors.cyan}${'='.repeat(60)}${colors.reset}`);
  console.log(`${colors.cyan}AGENT RESPONSE${colors.reset}`);
  console.log(`${colors.cyan}${'='.repeat(60)}${colors.reset}\n`);
  
  console.log(`${colors.blue}## PLAN${colors.reset}`);
  console.log(parsed.sections.plan);
  
  console.log(`\n${colors.blue}## PATCH${colors.reset}`);
  console.log(parsed.sections.patch);
  
  console.log(`\n${colors.blue}## DIFF SUMMARY${colors.reset}`);
  console.log(parsed.sections.summary);
  
  // Save successful output
  const successFile = path.join(ARTIFACTS_DIR, 'agent_success.txt');
  await fs.writeFile(successFile, output);
  console.log(`\n${colors.green}✅ Task completed successfully${colors.reset}`);
  console.log(`   Full output saved to: ${successFile}`);
}

main().catch(error => {
  console.error(`${colors.red}Error: ${error.message}${colors.reset}`);
  process.exit(1);
});