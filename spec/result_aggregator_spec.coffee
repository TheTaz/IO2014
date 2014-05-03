ResultAggregator = require "../src/result_aggregator"

describe "ResultAggregator", ->
  beforeEach ->
    @connectionManager = jasmine.createSpyObj 'connectionManager', ["onResultReady"]
    @resultAggregator = new ResultAggregator(@connectionManager)

  it "adds callback to connectionManager", ->
    expect(@connectionManager.onResultReady).toHaveBeenCalled()

  it "aggregates results", ->
    @merge_func = jasmine.createSpy("merge_func")
    @resultAggregator.aggregateOn(3, @merge_func)

    expect(@resultAggregator.getCurrentResult(3)).not.toBe(null)
    expect(@merge_func).toHaveBeenCalled()

  it "returns undefined if task with certin id doesn't exist", ->
    expect(@resultAggregator.getCurrentResult(3)).toBe(undefined)
