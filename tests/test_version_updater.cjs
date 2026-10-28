const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const config = require('../.versionrc.cjs');
const { updater } = config.bumpFiles[0];

test('use release tags as authority and bump the shell script', () => {
  assert.deepEqual(config.packageFiles, []);
  assert.equal(config.bumpFiles.length, 1);
  assert.equal(config.bumpFiles[0].filename, 'custom_bash_commands.sh');
});

test('read the real script version without executing the shell script', () => {
  const script = fs.readFileSync(
    path.join(__dirname, '..', 'custom_bash_commands.sh'), 'utf8',
  );
  assert.match(updater.readVersion(script), /^\d+\.\d+\.\d+/);
});

test('update patch, minor, major, and prerelease versions in place', () => {
  const prefix = '#!/usr/bin/env bash\n';
  const suffix = '\n# v4.0.0 remains in comments and other strings.\n'
    + 'printf "%s\\n" "v4.0.0"\n';
  const script = prefix + 'CBC_VERSION="v4.0.0"' + suffix;

  for (const version of ['4.0.2', '4.1.0', '5.0.0', '5.0.0-rc.1+build.2']) {
    const updated = updater.writeVersion(script, version);
    assert.equal(updated, prefix + `CBC_VERSION="v${version}"` + suffix);
    assert.equal(updater.readVersion(updated), version);
  }
});

test('preserve indentation, trailing whitespace, and CRLF line endings', () => {
  const script = '#!/bin/bash\r\n  CBC_VERSION="v4.0.0" \t\r\nexit\r\n';
  assert.equal(
    updater.writeVersion(script, '4.0.2'),
    '#!/bin/bash\r\n  CBC_VERSION="v4.0.2" \t\r\nexit\r\n',
  );
});

test('reject missing, duplicate, and malformed version assignments', () => {
  const invalidScripts = [
    '# no version assignment\n',
    'CBC_VERSION="v4.0.0"\nCBC_VERSION="v4.0.1"\n',
    'CBC_VERSION="v4.0.0"\nCBC_VERSION=invalid\n',
    'CBC_VERSION="4.0.0"\n',
    'CBC_VERSION=v4.0.0\n',
  ];

  for (const script of invalidScripts) {
    assert.throws(() => updater.readVersion(script), /Expected/);
    assert.throws(() => updater.writeVersion(script, '4.0.2'), /Expected/);
  }
});
