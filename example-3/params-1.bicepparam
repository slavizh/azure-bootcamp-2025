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
]

param endResult = toObject(dataInput, entry => entry.name, entry => {
  location: entry.location
  target: entry.target
})
