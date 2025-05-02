using none

var dataInput = [
  {
    name: 'foo1'
    location: 'loc1'
    target: 3
  }
  {
    name: 'foo2'
    location: 'loc1'
    target: 5
  }
  {
    name: 'foo3'
    location: 'loc2'
    target: 1
  }
  {
    name: 'test2'
    location: 'loc3'
    target: 6
  }
  {
    name: 'foo4'
    location: 'loc3'
  }
]

param endResult = toObject(
  filter(
    items(toObject(filter(dataInput, item => contains(item.name, 'foo')), entry => entry.name, entry => {
      location: entry.location
      target: entry.?target ?? 0
      totalTarget: reduce(
        map(dataInput, item => !contains(item.name, 'foo') ? 0 : item.?target ?? 0),
        0,
        (cur, next) => cur + next
      )
    })),
    entry => entry.value.totalTarget - entry.value.target > 4
  ),
  entry => entry.key,
  entry => entry.value
)
