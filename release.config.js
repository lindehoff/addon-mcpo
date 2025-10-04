/**
 * @type {import('semantic-release').GlobalConfig}
 */
module.exports = {
    "tagFormat": "v${version}",
    "branches": [
        "main"
    ],
    "plugins": [
        "@semantic-release/commit-analyzer",
        [
            "@semantic-release/release-notes-generator",
            {
                "preset": "angular",
                "writerOpts": {
                    "commitPartial": require('fs').readFileSync('.github/changelog-template.hbs', 'utf-8'),
                    "finalizeContext": (context) => {
                        for (const commitGroup of context.commitGroups) {
                            for (const commit of commitGroup.commits) {
                                const body = commit.body || '';
                                const releaseNotesMatch = body.match(/Release notes:\n([\s\S]*?)(\n\S|$)/);
                                
                                if (releaseNotesMatch) {
                                    commit.bodyLines = releaseNotesMatch[1]
                                        .split('\n')
                                        .filter(line => line.trim() !== '')
                                        .map(line => line.replace(/^- /, ''));
                                } else {
                                    commit.bodyLines = commit.body?.split('\n').filter((line) => line !== '') ?? [];
                                }
                            }
                        }
                        return context;
                    }
                },
                "presetConfig": {
                    "types": [
                        {"type": "feat", "section": "Features", "hidden": false},
                        {"type": "fix", "section": "Bug Fixes", "hidden": false},
                        {"type": "chore", "section": "Maintenance", "hidden": false}
                    ]
                }
            }
        ],
        [
            "@semantic-release/changelog",
            {
                "changelogFile": "mcpo/CHANGELOG.md",
                "changelogTitle": "# Changelog"
            }
        ],
        [
            "@semantic-release/exec",
            {
                "prepareCmd": "sed -i.bak 's/^version: \".*\"/version: \"${nextRelease.version}\"/' mcpo/config.yaml && rm -f mcpo/config.yaml.bak"
            }
        ],
        [
            "@semantic-release/git",
            {
                "assets": [
                    "mcpo/CHANGELOG.md",
                    "mcpo/config.yaml"
                ],
                "message": "chore(release): ${nextRelease.version}\n\n${nextRelease.notes}"
            }
        ],
        "@semantic-release/github"
    ]
};

