# finding the ligature tables:

1. goto: https://fontdrop.info/#/?darkmode=true
2. under Ligatures section you can search for the subtable lookup
   which contains your ligature
3. under Data section you can search for your <liga> (or whatever that you found)
   and then the 'features' section you should be able to find something like:
```json
{"tag":"liga","feature":{"featureParams":0,"lookupListIndexes":[14]}}
```
4. then you add this to the [Subtables] seciton in the config.cfg below.

additional ressources in order of relevance:
- https://github.com/ryanoasis/nerd-fonts/blob/master/readme.md#font-patcher
- https://github.com/ryanoasis/nerd-fonts/wiki/ScriptOptions
- https://github.com/ryanoasis/nerd-fonts/discussions/1514
- https://github.com/ryanoasis/nerd-fonts/blob/master/src/config.sample.cfg
- https://github.com/ORutherford/nerd-fonts/blob/9e38cef075f016301e10f9097590b3fb005fb47e/src/unpatched-fonts/Noto/Sans/config.json
- https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode#ligatures

> ts method is ass tho so just use https://www.glyphrstudio.com/app/ and do it by hand
