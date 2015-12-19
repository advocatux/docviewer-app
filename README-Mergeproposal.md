Prerequisites to approving a Merge Proposal (MP)
================================================

Over time, it has been found that insufficient testing by reviewers sometimes leads to doc viewer app trunk not buildable in Qtcreator due to manifest errors, or translation pot file not updated. As such, please follow the checklist below before top-approving a MP.

Checklist
=========

*   Does the MP add/remove user visible strings? If Yes, has the pot file been
    updated?

*   Does the MP change the UI? If Yes, has it been approved by design?

*   Did you perform an exploratory manual test run of your code change and any
    related functionality?

*   If the MP fixes a bug or implements a feature, are there accompanying unit
    and autopilot tests?

*   Is the doc viewer app trunk buildable and runnable using Qtcreator?

*   Was the debian changelog updated?

*   Was the copyright years updated if necessary?

The above checklist is more of a guideline to help doc viewer app trunk stay buildable,
stable and up to date.

