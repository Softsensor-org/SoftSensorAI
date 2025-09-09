#!/usr/bin/env node
import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

/**
 * Analyzes git diff to suggest acceptance criteria and telemetry based on code patterns
 */

// Pattern matchers for different detection types
const PATTERNS = {
  persistence: {
    localStorage: /localStorage\.(setItem|getItem|removeItem|clear)/g,
    sessionStorage: /sessionStorage\.(setItem|getItem|removeItem|clear)/g,
    indexedDB: /indexedDB\.(open|deleteDatabase)|objectStore\.(add|put|delete|get)/g,
    cookies: /document\.cookie|Cookies\.(set|get|remove)/g,
    reduxPersist: /redux-persist|persistStore|persistReducer/g
  },
  telemetry: {
    analytics: /analytics\.(track|identify|page|group|alias)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    posthog: /posthog\.(capture|identify|alias|set)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    rudder: /rudderanalytics\.(track|identify|page)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    amplitude: /amplitude\.(logEvent|identify|setUserId)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    mixpanel: /mixpanel\.(track|identify|alias)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    gtag: /gtag\s*\(\s*['"`]event['"`]\s*,\s*['"`]([^'"`]+)['"`]/g
  },
  api: {
    fetch: /fetch\s*\(\s*['"`]([^'"`]+)['"`]/g,
    axios: /axios\.(get|post|put|patch|delete|request)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    httpMethod: /(GET|POST|PUT|PATCH|DELETE)\s+['"`]([^'"`]+)['"`]/g,
    apiRoute: /router\.(get|post|put|patch|delete)\s*\(\s*['"`]([^'"`]+)['"`]/g,
    endpoint: /app\.(get|post|put|patch|delete)\s*\(\s*['"`]([^'"`]+)['"`]/g
  },
  sorting: {
    sort: /\.sort\s*\(|sort\s*:/gi,
    orderBy: /orderBy\s*\(|ORDER\s+BY/gi,
    sortBy: /sortBy\s*\(|\.sortBy\s*\(/g
  }
};

export function analyzeGitDiff(baseSha = 'HEAD~1', headSha = 'HEAD') {
  const suggestions = {
    criteria: [],
    telemetry: { events: [] },
    tests: []
  };

  try {
    // Get list of changed files
    const changedFiles = execSync(`git diff --name-only ${baseSha}..${headSha}`, { encoding: 'utf-8' })
      .trim()
      .split('\n')
      .filter(f => f && !f.startsWith('.softsensor/'));

    for (const file of changedFiles) {
      if (!file.match(/\.(js|jsx|ts|tsx|mjs)$/)) continue;

      // Get the diff for this file
      let diff;
      try {
        diff = execSync(`git diff ${baseSha}..${headSha} -- "${file}"`, { encoding: 'utf-8' });
      } catch {
        continue;
      }

      // Extract added lines (lines starting with +)
      const addedLines = diff
        .split('\n')
        .filter(line => line.startsWith('+') && !line.startsWith('+++'))
        .map(line => line.substring(1))
        .join('\n');

      // Detect persistence patterns
      for (const [storage, pattern] of Object.entries(PATTERNS.persistence)) {
        if (pattern.test(addedLines)) {
          const criterionId = `persist-${storage.toLowerCase()}`;
          if (!suggestions.criteria.find(c => c.id === criterionId)) {
            suggestions.criteria.push({
              id: criterionId,
              must: true,
              text: `State persists across reloads using ${storage}`,
              tests: [`tests/contract/<ID>/${criterionId}.contract.spec.ts`],
              suggested: true
            });
            suggestions.tests.push({
              file: `${criterionId}.contract.spec.ts`,
              type: 'persistence',
              storage
            });
          }
        }
      }

      // Detect telemetry patterns
      for (const [lib, pattern] of Object.entries(PATTERNS.telemetry)) {
        let match;
        const regex = new RegExp(pattern.source, pattern.flags);
        while ((match = regex.exec(addedLines)) !== null) {
          const eventName = match[1] || match[2];
          if (eventName && !suggestions.telemetry.events.includes(eventName)) {
            suggestions.telemetry.events.push(eventName);
            const criterionId = `telemetry-${eventName.toLowerCase().replace(/[^a-z0-9]/g, '-')}`;
            suggestions.criteria.push({
              id: criterionId,
              must: true,
              text: `Emits '${eventName}' telemetry event on action`,
              tests: [`tests/contract/<ID>/${criterionId}.contract.spec.ts`],
              suggested: true
            });
            suggestions.tests.push({
              file: `${criterionId}.contract.spec.ts`,
              type: 'telemetry',
              eventName
            });
          }
        }
      }

      // Detect API changes
      if (file.includes('api/') || file.includes('routes/') || file.includes('server/')) {
        for (const [type, pattern] of Object.entries(PATTERNS.api)) {
          if (pattern.test(addedLines)) {
            const criterionId = 'api-contract';
            if (!suggestions.criteria.find(c => c.id === criterionId)) {
              suggestions.criteria.push({
                id: criterionId,
                must: true,
                text: 'API endpoints return expected status codes and response schemas',
                tests: [`tests/contract/<ID>/api.contract.spec.ts`],
                suggested: true
              });
              suggestions.tests.push({
                file: 'api.contract.spec.ts',
                type: 'api'
              });
            }
            break;
          }
        }
      }

      // Detect sorting patterns
      for (const [type, pattern] of Object.entries(PATTERNS.sorting)) {
        if (pattern.test(addedLines)) {
          const criterionId = 'sort-invariance';
          if (!suggestions.criteria.find(c => c.id === criterionId)) {
            suggestions.criteria.push({
              id: criterionId,
              must: true,
              text: 'Existing sort order semantics preserved',
              tests: [`tests/contract/<ID>/${criterionId}.contract.spec.ts`],
              suggested: true
            });
            suggestions.tests.push({
              file: `${criterionId}.contract.spec.ts`,
              type: 'sorting'
            });
          }
          break;
        }
      }
    }
  } catch (error) {
    console.error('Error analyzing git diff:', error.message);
  }

  return suggestions;
}

export function generateTestScaffold(testInfo, contractId) {
  const templates = {
    persistence: `describe('${contractId}: Persistence', () => {
  it('should persist ${testInfo.storage} state across reloads', async () => {
    // TODO: Set initial state in ${testInfo.storage}
    // TODO: Reload page/component
    // TODO: Verify state is restored from ${testInfo.storage}
  });
});`,
    telemetry: `describe('${contractId}: Telemetry', () => {
  it('should emit "${testInfo.eventName}" event', async () => {
    // TODO: Set up telemetry spy/mock
    // TODO: Trigger action that should emit event
    // TODO: Verify event was sent with correct payload
  });
});`,
    api: `describe('${contractId}: API Contract', () => {
  it('should return expected status and schema', async () => {
    // TODO: Make API request
    // TODO: Verify status code (200, 201, etc)
    // TODO: Validate response schema
    // TODO: Test error cases (404, 400, etc)
  });
});`,
    sorting: `describe('${contractId}: Sort Invariance', () => {
  it('should preserve existing sort order behavior', async () => {
    // TODO: Create test data with known order
    // TODO: Apply sorting operation
    // TODO: Verify order matches expected behavior
  });
});`
  };

  return templates[testInfo.type] || '// TODO: Implement test';
}