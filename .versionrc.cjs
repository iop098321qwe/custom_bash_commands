function versionAssignment(contents) {
  const assignments = [
    ...contents.matchAll(/^[\t ]*CBC_VERSION=[^\r\n]*\r?$/gm),
  ];

  if (assignments.length !== 1) {
    throw new Error('Expected exactly one CBC_VERSION assignment.');
  }

  const assignment = assignments[0];
  const parts = /^([\t ]*CBC_VERSION="v)([^"\r\n]+)("[\t ]*\r?)$/
    .exec(assignment[0]);

  if (!parts) {
    throw new Error('Expected CBC_VERSION="v<version>".');
  }

  return {
    index: assignment.index,
    text: assignment[0],
    prefix: parts[1],
    version: parts[2],
    suffix: parts[3],
  };
}

const updater = {
  readVersion(contents) {
    return versionAssignment(contents).version;
  },

  writeVersion(contents, version) {
    const assignment = versionAssignment(contents);
    return contents.slice(0, assignment.index)
      + assignment.prefix + version + assignment.suffix
      + contents.slice(assignment.index + assignment.text.length);
  },
};

module.exports = {
  // Release tags are authoritative even if the script version is stale.
  packageFiles: [],
  bumpFiles: [{ filename: 'custom_bash_commands.sh', updater }],
};
