The example from the presentation [Better Code for a Better World]().

Our mission: create a form for the user to fill out. It should only allow submission if the form is valid. A form is valid if the user's entered a value for each field, and if the email and re-enter email fields match.

We want to minimize our statefulness for our own sanity. This means any non-essential state should be derived and driven entirely by the essential state.