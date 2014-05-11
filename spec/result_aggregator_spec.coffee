ResultAggregator = require "../src/result_aggregator"

describe "ResultAggregator", ->
  beforeEach ->
    @connectionManager = jasmine.createSpyObj 'connectionManager', ["on"]
    @resultAggregator = new ResultAggregator(@connectionManager)

  it "adds callback to connectionManager", ->
    expect(@connectionManager.on).toHaveBeenCalled()

  it "aggregates results", ->
    @merge_func = jasmine.createSpy("merge_func")
    @resultAggregator.aggregateOn(3, @merge_func)

    expect(@resultAggregator.getCurrentResult(3)).not.toBe(null)
    expect(@merge_func).toHaveBeenCalled()

  it "returns undefined if task with certin id doesn't exist", ->
    expect(@resultAggregator.getCurrentResult(3)).toBe(undefined)

  it "aggregates results", ->
    @resultAggregator.aggregateOn(3, (numbers) -> numbers.reduce (s, t) -> s + t)
    @resultAggregator.addResultFor(3, 1, 5)
    @resultAggregator.addResultFor(3, 2, 8)
    expect(@resultAggregator.getCurrentResult(3).mergedResult).toBe(13)
