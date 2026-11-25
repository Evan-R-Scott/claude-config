# Lens: generalization and adaptability (applies to every target, where it applies)

A rule, check, default, test or fix that works only for the examples the author had in hand is a defect, even when every example passes. Ask of each one: what is it derived from, and what valid case would it get wrong?

- **Basis:** is each rule derived from a contract (a schema, documented fields, the owning system's code or its owner), a stated principle, or only observed samples? A rule inferred from a few samples must say so, be tagged as such, and be confirmed by the owner or a larger sample. Look at the sample size behind a claim like "always", "never", "only", "optional".
- **Fitted to the example:** ids from a sample, example names, sample paths, one environment, product, customer, tenant, account or input, a key or message string matched as text where a structured field exists, a count that happened to be seen. Do these appear inside a rule or a default, and not only as evidence?
- **Variation:** vary what the rule should not depend on (names and their length, ordering, which optional parts are present, extra unknown fields, another instance of the same thing, another product or dialect, empty and large cases) and check the outcome does not change. Does a valid case outside the examples get rejected, or an invalid one accepted?
- **Safe default for the unknown:** when the input is not recognized, does the code degrade to the safe outcome (refuse, ask, mark unverified), or does it guess toward the examples?
- **Product-specific versus general:** is what belongs to one product, tool or environment kept as data or configuration (a setting, a manifest, a profile or plugin), separate from the engine logic, and overridable? Hardcoded names, paths, hosts, commands, versions, thresholds and limits in logic are findings unless they are documented defaults that can be changed.
- **Numbers and defaults:** each limit or threshold should have a reason and a way to change it; a number presented as a fact because it was observed once is a finding.
- **Tests:** do they cover the rule or only the saved examples? A test suite built only from the same examples that shaped the rule proves nothing about other cases: ask for mutated and synthetic variants, and for a case that should fail.
- **Findings and their fixes:** a finding must name the class of issue, not just the instance, and its "Direction" must fix the class (check the fix against the variations above). A fix that patches the one reported case is a finding of its own.

Do not invent generality: where the target is deliberately specific (a one-off script, a stated scope), say that it is and do not ask for abstraction the need does not justify.
