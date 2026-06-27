# Specs: <component name>

<!-- One spec file per component or logical grouping. Name the file after the component: tp.md, install.md, etc. -->
<!-- Delete this file and replace it with real spec files. -->

## S-<COMPONENT>-01: <short title in plain English>

GIVEN <system state or precondition>
WHEN <user action or trigger>   ← omit this line if no trigger is needed
THEN <observable outcome>
AND <additional outcome>        ← add as many AND lines as needed

## S-<COMPONENT>-02: <short title>

GIVEN <precondition>
THEN <outcome>

<!--
Naming rules:
- COMPONENT is an uppercase abbreviation of the component name: TP, TRUN, ZSH, TMUX, INSTALL, etc.
- NN is a two-digit sequence within the file: 01, 02, 03 ...
- IDs are stable — do not renumber after assignment
- One scenario per spec block; do not combine unrelated behaviours
-->
