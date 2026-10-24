# Landing-page claims and how we back them

Internal. Every promise on the welcome page (`lib/screens/welcome_screen.dart`) must map to something the backend does and a metric we track. If we can't measure a claim, we soften the copy until we can.

**Positioning:** the exam-readiness engine for your course. We sell the loop that joins the features, not the features one by one:

> Diagnose the mistake → prioritise by weakness × exam frequency → fix it in your lecturer's terms → prove it on fresh questions.

| Section | Claim on the page | What the backend must do | How we prove it |
|---|---|---|---|
| Your course, mapped | Your course becomes a map of linked ideas, not a folder of files | Extract the concepts in each source and link them across documents ("128 ideas linked") | Show the student the concept map; spot-check link accuracy |
| In your lecturer's terms | Page-exact answers, framed the way your course teaches it, and it says when your materials don't cover something | Retrieval with page anchors, plus an "outside your materials" path | Citation accuracy on a test set; zero uncited claims |
| Why you're wrong | We find why you're wrong, not just where | Tag each wrong answer with a misconception type; track recurrence over time | Misconceptions recur less after remediation |
| What to study next | Ranked by how weak you are × how often your past papers ask it | Topic frequency across past papers, combined with per-concept mastery | Priority order matches a teacher's ranking on sample courses |
| Marked like the real exam | Practice weighted to what examiners ask, marked against the real rubric | Rubric-based marking of written answers; missed points feed misconception tags | Marking agreement with a human marker |
| Proof you fixed it | Retested on questions you haven't seen | Reassess with new items, never repeats; update mastery | Before/after scores on unseen questions |

## Copy rules

- Never name competitors or say "better than". Make specific mechanism claims ("we track the mistake, not just the topic").
- Make comparative claims ("students improved X% more") only after a head-to-head pilot measured on fresh questions.
- No grade predictions until they are calibrated against real results. Say "exam readiness" and show a range (the page shows 60–70%).
- The demo figures on the page (Regularisation 41%, 4 of 5 past papers, the L1/L2 misconception) are sample data from the Machine Learning demo library, not user results.
