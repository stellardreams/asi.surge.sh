const IPFSBlueprintStorage = require('../scripts/ipfs-storage');
const fs = require('fs');

class DesignValidator {
    constructor() {
        this.storage = new IPFSBlueprintStorage();
        this.validationRules = {
            '3-stage-AMU': [
                { check: 'selfReplication', required: true },
                { check: 'reorientation', required: true },
                { check: 'TRL', min: 1, max: 9 }
            ],
            "O'Neill-cylinder": [
                { check: 'length', min: 10, max: 100 },
                { check: 'radius', min: 1, max: 20 },
                { check: 'rotationSpeed', max: 3 } // RPM
            ]
        };
    }

    async validateDesignFile(filePath) {
        try {
            const blueprint = JSON.parse(fs.readFileSync(filePath, 'utf8'));
            const errors = [];
            
            // Check if blueprint has required fields
            if (!blueprint.type) errors.push('Missing blueprint type');
            if (!blueprint.author) errors.push('Missing author information');
            if (!blueprint.components || blueprint.components.length === 0) {
                errors.push('Missing components list');
            }
            
            // Validate against type-specific rules
            if (this.validationRules[blueprint.type]) {
                for (const rule of this.validationRules[blueprint.type]) {
                    if (rule.required && !blueprint[rule.check]) {
                        errors.push(`${rule.check} is required for ${blueprint.type}`);
                    }
                }
            }
            
            // Check for duplicate component names
            const componentNames = new Set();
            for (const component of blueprint.components) {
                if (componentNames.has(component.name)) {
                    errors.push(`Duplicate component name: ${component.name}`);
                }
                componentNames.add(component.name);
            }
            
            // Validate AMU specific rules
            if (blueprint.type === '3-stage-AMU') {
                if (!blueprint.selfReplication) {
                    errors.push('3-stage-AMU must have self-replication capability');
                }
                if (blueprint.TRL < 1 || blueprint.TRL > 9) {
                    errors.push(`TRL must be between 1 and 9, got ${blueprint.TRL}`);
                }
            }
            
            return {
                isValid: errors.length === 0,
                errors: errors,
                blueprint: blueprint
            };
        } catch (error) {
            return {
                isValid: false,
                errors: [`Parse error: ${error.message}`]
            };
        }
    }

    async validateDesignCID(cid) {
        try {
            const blueprint = await this.storage.getBlueprint(cid);
            return await this.validateDesignFile(blueprint);
        } catch (error) {
            return {
                isValid: false,
                errors: [`IPFS retrieval error: ${error.message}`]
            };
        }
    }

    async validateAllBlueprints() {
        const results = [];
        const blueprints = [
            { path: 'designs/AMU-v1.json' },
            { path: 'designs/AMU-v2.json' },
            { path: "designs/O'Neill-v1.json" }
        ];
        
        for (const blueprint of blueprints) {
            if (fs.existsSync(blueprint.path)) {
                const result = await this.validateDesignFile(blueprint.path);
                results.push(result);
            }
        }
        
        return results;
    }
}

// Main execution
(async () => {
    const validator = new DesignValidator();
    const results = await validator.validateAllBlueprints();
    
    let allValid = true;
    let report = [];
    
    for (const result of results) {
        if (!result.isValid) {
            allValid = false;
            report.push(`❌ Design ${result.blueprint?.name || 'unknown'} failed:`);
            report.push(...result.errors.map(e => `  - ${e}`));
        } else {
            report.push(`✅ Design ${result.blueprint?.name || 'unknown'} is valid`);
        }
    }
    
    if (!allValid) {
        console.error('Validation failed:');
        console.error(report.map(line => line.toString()).join('\n'));
        process.exit(1);
    } else {
        console.log('All designs validated successfully!');
        process.exit(0);
    }
})();