Roster::Cohort.add '1407' do |cohort|
  # uncomment to validate the inputs
  # cohort.stderr = $stdout

  cohort.set_students [
    "Student1",
    "Student2",
    "Student3",
    "Student4",
  ]

  cohort.add_project :lightning_talk_groups, [
    ["Student1", "Student2"],
    ["Student3", "Student4"],
  ]

  cohort.add_project :event_reporter, [
    ["Student1", "Student2"],
  ]

  cohort.add_project :event_reporter, [
    ["Student3", "Student2"],
  ]
end
