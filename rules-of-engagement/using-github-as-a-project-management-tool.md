# GitHub as a project management tool

Bürokratt uses [its GitHub accout](https://github.com/buerokratt) for both [storing source code](https://github.com/orgs/buerokratt/repositories) and [managing projects](https://github.com/orgs/buerokratt/projects?query=is%3Aopen&type=new).


## Milestones
Milestones are goals grouped by business logic.

All milestones must contain GitHub issues.


## Issues

### User stories
All issues must contain business-level user stories in the following format:
```
AS A(N) {PERSONA}...
I WANT TO ...
SO THAT ...
```
#### Personas used in user stories

All personas in user stories must be described in [Bürokratt Glossary -> Personas](https://github.com/buerokratt/Buerokratt-onboarding/blob/main/glossary.md#personas).

Adding new personas must be approvad by Bürokratt core team.

#### Example of a user story

```
AS AN Administrative User
I WANT TO be able to have multiple search options in chat history
SO THAT I could find specific chat by date, CSA's name, End Users name and personal ID
```

User stories **do not** contain technical requirements.

User stories are almost always written and/or approved by product owners.


### Acceptance Criteria

In addition to user story, every issue must contain (a list of) acceptance criteria(s) describing [all conditions that a software product must satisfy to be accepted by a user, customer or a stakeholder.](https://www.productplan.com/glossary/acceptance-criteria/#:~:text=Acceptance%20Criteria%20Definition%201%3A%20%E2%80%9CConditions,meet.%E2%80%9D%20(via%20Google))


## Labels

### Architecture Design Records

Labels in a form of `ADR: Xyz` mean that this issue must be developed by following the concept of some specific architecture design. For example, issue containing a lable `ADR: Push technologies` must follow the concepts of [push technologies](https://github.com/buerokratt/Buerokratt-onboarding/blob/main/architecture-design-records.md#push-technologies).

In case of changing the current architecture design for given topic, these changes must be covered in an appropriate topic of Architecture Design Records as well.
