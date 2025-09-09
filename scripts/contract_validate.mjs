#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import crypto from 'crypto';
import { glob } from 'glob';
import yaml from 'js-yaml';

const CONTRACTS_DIR = 'contracts';
const HASH_DIR = '.softsensor';

// Parse contract file
async function parseContract(filePath) {
  const content = await fs.readFile(filePath, 'utf-8');
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  
  if (!match) {
    throw new Error(`No YAML front-matter found in ${filePath}`);
  }
  
  const frontMatter = yaml.load(match[1]);
  return { filePath, frontMatter };
}

// Validate required fields
function validateContract(contract) {
  const { filePath, frontMatter } = contract;
  const errors = [];
  
  // Required fields
  const required = ['id', 'title', 'status', 'owner', 'version', 'allowed_globs', 'acceptance_criteria'];
  for (const field of required) {
    if (!frontMatter[field]) {
      errors.push(`Missing required field: ${field}`);
    }
  }
  
  // Validate status
  const validStatuses = ['planned', 'in_progress', 'achieved', 'maintained', 'deprecated'];
  if (frontMatter.status && !validStatuses.includes(frontMatter.status)) {
    errors.push(`Invalid status: ${frontMatter.status}. Must be one of: ${validStatuses.join(', ')}`);
  }
  
  // Validate allowed_globs is array
  if (frontMatter.allowed_globs && !Array.isArray(frontMatter.allowed_globs)) {
    errors.push('allowed_globs must be an array');
  }
  
  // Validate acceptance_criteria
  if (frontMatter.acceptance_criteria) {
    if (!Array.isArray(frontMatter.acceptance_criteria)) {
      errors.push('acceptance_criteria must be an array');
    } else if (frontMatter.acceptance_criteria.length === 0) {
      errors.push('acceptance_criteria cannot be empty');
    } else {
      frontMatter.acceptance_criteria.forEach((ac, index) => {
        if (!ac.id) errors.push(`acceptance_criteria[${index}] missing id`);
        if (!ac.must) errors.push(`acceptance_criteria[${index}] missing must`);
        if (!ac.text) errors.push(`acceptance_criteria[${index}] missing text`);
        if (!ac.tests || !Array.isArray(ac.tests)) {
          errors.push(`acceptance_criteria[${index}] missing or invalid tests array`);
        }
      });
    }
  }
  
  // Validate optional budgets
  if (frontMatter.budgets) {
    if (typeof frontMatter.budgets !== 'object') {
      errors.push('budgets must be an object');
    } else {
      if (frontMatter.budgets.latency_ms_p50 !== undefined) {
        if (typeof frontMatter.budgets.latency_ms_p50 !== 'number') {
          errors.push('budgets.latency_ms_p50 must be a number');
        }
      }
      if (frontMatter.budgets.bundle_kb_delta_max !== undefined) {
        if (typeof frontMatter.budgets.bundle_kb_delta_max !== 'number') {
          errors.push('budgets.bundle_kb_delta_max must be a number');
        }
      }
    }
  }
  
  // Validate optional telemetry
  if (frontMatter.telemetry) {
    if (typeof frontMatter.telemetry !== 'object') {
      errors.push('telemetry must be an object');
    } else if (frontMatter.telemetry.events) {
      if (!Array.isArray(frontMatter.telemetry.events)) {
        errors.push('telemetry.events must be an array');
      } else {
        frontMatter.telemetry.events.forEach((event, index) => {
          if (typeof event !== 'string') {
            errors.push(`telemetry.events[${index}] must be a string`);
          }
        });
      }
    }
  }
  
  return errors;
}

// Compute Contract-Hash
function computeContractHash(frontMatter) {
  const hashInput = {
    id: frontMatter.id,
    allowed_globs: frontMatter.allowed_globs,
    acceptance_criteria: frontMatter.acceptance_criteria,
    budgets: frontMatter.budgets || null,
    telemetry: frontMatter.telemetry || null
  };
  
  const jsonString = JSON.stringify(hashInput, null, 0);
  const hash = crypto.createHash('sha256').update(jsonString).digest('hex');
  return hash;
}

// Save hash to file
async function saveHash(id, hash) {
  await fs.mkdir(HASH_DIR, { recursive: true });
  const hashFile = path.join(HASH_DIR, `${id}.hash`);
  await fs.writeFile(hashFile, hash);
  return hashFile;
}

// Main validation
async function validateAllContracts() {
  console.log('🔍 Validating contracts...\n');
  
  // Find all contract files
  const contractFiles = await glob(`${CONTRACTS_DIR}/*.contract.md`);
  
  if (contractFiles.length === 0) {
    console.log('No contract files found.');
    return;
  }
  
  const contracts = [];
  const ids = new Set();
  let hasErrors = false;
  
  // Parse and validate each contract
  for (const file of contractFiles) {
    try {
      const contract = await parseContract(file);
      contracts.push(contract);
      
      // Check for duplicate IDs
      if (ids.has(contract.frontMatter.id)) {
        console.error(`❌ ${file}: Duplicate ID: ${contract.frontMatter.id}`);
        hasErrors = true;
      }
      ids.add(contract.frontMatter.id);
      
      // Validate contract
      const errors = validateContract(contract);
      if (errors.length > 0) {
        console.error(`❌ ${file}:`);
        errors.forEach(err => console.error(`   - ${err}`));
        hasErrors = true;
      } else {
        // Compute and save hash
        const hash = computeContractHash(contract.frontMatter);
        const shortHash = hash.substring(0, 8);
        await saveHash(contract.frontMatter.id, hash);
        console.log(`✅ ${contract.frontMatter.id}: ${contract.frontMatter.title} [${shortHash}]`);
      }
    } catch (error) {
      console.error(`❌ ${file}: ${error.message}`);
      hasErrors = true;
    }
  }
  
  console.log(`\n📊 Validated ${contracts.length} contracts`);
  
  if (hasErrors) {
    console.error('\n❌ Validation failed');
    process.exit(1);
  } else {
    console.log('✅ All contracts valid');
  }
}

// Run validation
validateAllContracts().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});