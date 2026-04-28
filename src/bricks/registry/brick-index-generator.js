/**
 * Brick Index Generator
 * 
 * Automatically generates and maintains the machine-readable brick registry
 * by scanning the codebase for @Brick annotations and extracting metadata.
 * 
 * @example
 * ```javascript
 * const generator = new BrickIndexGenerator();
 * const index = await generator.generateIndex();
 * await generator.saveIndex();
 * ```
 */
export class BrickIndexGenerator {
  constructor(options = {}) {
    this.options = {
      brickDir: options.brickDir || 'src/bricks',
      outputFile: options.outputFile || 'docs/brick-index.json',
      includeTests: options.includeTests ?? true,
      ...options
    };
    this.bricks = [];
  }

  /**
   * Scans directory for brick files
   * 
   * @private
   * @param {string} dir - Directory to scan
   * @returns {Promise<string[]>} Array of file paths
   */
  async scanDirectory(dir) {
    const fs = await import('fs/promises');
    const path = await import('path');
    
    const files = [];
    
    try {
      const entries = await fs.readdir(dir, { withFileTypes: true });
      
      for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        
        if (entry.isDirectory()) {
          files.push(...await this.scanDirectory(fullPath));
        } else if (this.isBrickFile(entry.name)) {
          files.push(fullPath);
        }
      }
    } catch (error) {
      if (error.code !== 'ENOENT') {
        console.warn(`Warning: Could not scan directory ${dir}:`, error.message);
      }
    }
    
    return files;
  }

  /**
   * Checks if file is a brick file
   * 
   * @private
   * @param {string} filename - File name
   * @returns {boolean} True if brick file
   */
  isBrickFile(filename) {
    return /\.(js|ts|jsx|tsx)$/.test(filename) && 
           !filename.endsWith('.test.js') && 
           !filename.endsWith('.test.ts') &&
           !filename.endsWith('.spec.js') &&
           !filename.endsWith('.spec.ts');
  }

  /**
   * Extracts JSDoc comment from file content
   * 
   * @private
   * @param {string} content - File content
   * @returns {string|null} JSDoc comment or null
   */
  extractJSDoc(content) {
    const jsdocRegex = /\/\*\*([\s\S]*?)\*\//;
    const match = content.match(jsdocRegex);
    return match ? match[0] : null;
  }

  /**
   * Parses JSDoc tags
   * 
   * @private
   * @param {string} jsdoc - JSDoc comment
   * @returns {Object} Parsed tags
   */
  parseJSDocTags(jsdoc) {
    const tags = {
      description: '',
      params: [],
      returns: null,
      example: null,
      throws: []
    };

    // Extract description (first line after /**)
    const descMatch = jsdoc.match(/\/\*\*\s*\n?\s*\*?\s*([^@\n]+)/);
    if (descMatch) {
      tags.description = descMatch[1].trim();
    }

    // Extract @param tags
    const paramMatches = jsdoc.matchAll(/@param\s+{([^}]+)}\s+(\S+)\s*-?\s*([^\n@]*)/g);
    for (const match of paramMatches) {
      tags.params.push({
        type: match[1],
        name: match[2],
        description: match[3].trim()
      });
    }

    // Extract @returns tag
    const returnsMatch = jsdoc.match(/@returns\s+{([^}]+)}\s*([^\n@]*)/);
    if (returnsMatch) {
      tags.returns = {
        type: returnsMatch[1],
        description: returnsMatch[2].trim()
      };
    }

    // Extract @example
    const exampleMatch = jsdoc.match(/@example\s*\n?\s*```[\s\S]*?```/);
    if (exampleMatch) {
      tags.example = exampleMatch[0];
    }

    // Extract @throws tags
    const throwsMatches = jsdoc.matchAll(/@throws\s+{([^}]+)}\s*([^\n@]*)/g);
    for (const match of throwsMatches) {
      tags.throws.push({
        type: match[1],
        description: match[2].trim()
      });
    }

    return tags;
  }

  /**
   * Analyzes a brick file and extracts metadata
   * 
   * @private
   * @param {string} filePath - Path to brick file
   * @returns {Promise<Object>} Brick metadata
   */
  async analyzeBrick(filePath) {
    const fs = await import('fs/promises');
    const path = await import('path');

    const content = await fs.readFile(filePath, 'utf8');
    const jsdoc = this.extractJSDoc(content);
    const tags = jsdoc ? this.parseJSDocTags(jsdoc) : {};

    const relativePath = path.relative(process.cwd(), filePath);
    const ext = path.extname(filePath);
    const name = path.basename(filePath, ext);

    // Determine brick type from file path
    let type = 'utility';
    let category = 'general';
    
    if (filePath.includes('/validation/')) {
      type = 'validation';
      category = 'validation';
    } else if (filePath.includes('/services/')) {
      type = 'service';
      category = 'service';
    } else if (filePath.includes('/contracts/')) {
      type = 'contract';
      category = 'blockchain';
    }

    // Count lines
    const lines = content.split('\n').length;

    // Check for dependencies
    const importMatches = content.matchAll(/import\s+.*?from\s+['"]([^'"]+)['"]/g);
    const dependencies = [];
    for (const match of importMatches) {
      const dep = match[1];
      if (!dep.startsWith('.') && !dep.startsWith('/')) {
        dependencies.push(dep);
      }
    }

    return {
      id: name.toLowerCase().replace(/\s+/g, '-'),
      name: name,
      type: type,
      category: category,
      description: tags.description || 'No description provided',
      file: relativePath,
      language: ext === '.ts' || ext === '.tsx' ? 'typescript' : 'javascript',
      lines: lines,
      dependencies: dependencies,
      testCoverage: 0, // Would need coverage data
      status: 'active',
      parameters: tags.params,
      returns: tags.returns,
      examples: tags.example ? [tags.example] : [],
      tags: [category, type],
      author: 'system',
      lastModified: new Date().toISOString()
    };
  }

  /**
   * Loads existing index if it exists
   * 
   * @private
   * @returns {Promise<Object|null>} Existing index or null
   */
  async loadExistingIndex() {
    const fs = await import('fs/promises');
    
    try {
      const content = await fs.readFile(this.options.outputFile, 'utf8');
      return JSON.parse(content);
    } catch (error) {
      return null;
    }
  }

  /**
   * Generates the brick index
   * 
   * @returns {Promise<Object>} Complete brick index
   */
  async generateIndex() {
    const fs = await import('fs/promises');
    
    // Scan for brick files
    const brickFiles = await this.scanDirectory(this.options.brickDir);
    
    // Analyze each brick
    this.bricks = [];
    for (const file of brickFiles) {
      try {
        const brick = await this.analyzeBrick(file);
        this.bricks.push(brick);
      } catch (error) {
        console.warn(`Warning: Could not analyze ${file}:`, error.message);
      }
    }

    // Load existing index to preserve metadata
    const existingIndex = await this.loadExistingIndex();
    
    // Merge with existing data
    if (existingIndex && existingIndex.bricks) {
      const existingMap = new Map();
      existingIndex.bricks.forEach(b => existingMap.set(b.id, b));
      
      this.bricks.forEach(brick => {
        if (existingMap.has(brick.id)) {
          // Preserve manual metadata
          const existing = existingMap.get(brick.id);
          brick.status = existing.status || brick.status;
          brick.author = existing.author || brick.author;
          brick.testCoverage = existing.testCoverage || 0;
          brick.tags = [...new Set([...brick.tags, ...(existing.tags || [])])];
        }
      });
    }

    // Calculate statistics
    const statistics = {
      total: this.bricks.length,
      byType: {},
      byStatus: {},
      averageTestCoverage: 0,
      totalLines: this.bricks.reduce((sum, b) => sum + b.lines, 0)
    };

    this.bricks.forEach(brick => {
      statistics.byType[brick.type] = (statistics.byType[brick.type] || 0) + 1;
      statistics.byStatus[brick.status] = (statistics.byStatus[brick.status] || 0) + 1;
      statistics.averageTestCoverage += brick.testCoverage;
    });

    if (this.bricks.length > 0) {
      statistics.averageTestCoverage = Math.round(statistics.averageTestCoverage / this.bricks.length);
    }

    return {
      version: '2.0',
      generated: new Date().toISOString(),
      description: 'Machine-readable catalog of all Bricks in the project',
      bricks: this.bricks.sort((a, b) => a.name.localeCompare(b.name)),
      statistics: statistics,
      metadata: {
        project: 'Awakened Imagination Core',
        repository: 'https://github.com/stellardreams/asi.surge.sh',
        documentation: 'https://github.com/stellardreams/asi.surge.sh/blob/main/.kilo/plans/recursive-mandelbrot.md',
        standards: 'docs/BRICK_STANDARDS.md',
        sop: 'docs/SOPs/brick-creation.md',
        generator: 'BrickIndexGenerator v2.0'
      }
    };
  }

  /**
   * Saves the index to file
   * 
   * @returns {Promise<void>}
   */
  async saveIndex() {
    const fs = await import('fs/promises');
    const index = await this.generateIndex();
    
    await fs.mkdir(path.dirname(this.options.outputFile), { recursive: true });
    await fs.writeFile(
      this.options.outputFile,
      JSON.stringify(index, null, 2)
    );
    
    console.log(`✅ Brick index saved to ${this.options.outputFile}`);
    console.log(`   Total bricks: ${index.statistics.total}`);
    console.log(`   Total lines: ${index.statistics.totalLines}`);
  }
}

// CLI support
if (import.meta.url === `file://${process.argv[1]}`) {
  const generator = new BrickIndexGenerator();
  generator.saveIndex().catch(console.error);
}
