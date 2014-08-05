SG.Giveaways.Active.Graphs =

  initialize: ->
    if @graphPlaceholderEl().length
      @graphData = []
      @initGraphData()
      @plotWithOptions()

  plotWithOptions: ->
    $.plot @graphPlaceholderEl(), @graphData, @graphOptions

  initGraphData: ->

    @graphDatasets = {}

    if @flot_views()
      @graphDatasets["view_count"] =
        label: "Views"
        data: @flot_views()

    if @flot_page_likes()
      @graphDatasets["page_likes"] =
        label: "Likes"
        data: @flot_page_likes()

    if @flot_entries()
      @graphDatasets["entry_count"] =
        label: "Entries"
        data: @flot_entries()

    if @flot_shares()
      @graphDatasets["shares"] =
        label: "Shares"
        data: @flot_shares()

    for key, val of @graphDatasets
      @graphData.push @graphDatasets[key]

  graphOptions:
    series:
      downsample:
        threshold: 50
      stack: false
      lines:
        show: true
        lineWidth: 2
        fill: false
      shadowSize: 1
      grow:
        active: true
        steps: 50
      points:
        radius: 4
        show: true
    xaxis:
      mode: "time"
      tickSize: [1, "day"]
      minTickSize: [1, "day"]
    yaxis:
      tickDecimals: 0
      ticks: 10
      min: 0
    grid:
      hoverable: true
      clickable: true
      tickColor: "#f0f0f0"
      borderWidth: 1
      color: '#f0f0f0'
    colors: ["#fb6b5b","#4cc0c1","#65bd77","#ffc333"]
    legend:
      noColumns: 4
      position: 'ne'
      container: '#graph_legend'
    tooltip: true
    tooltipOpts:
      content: "<div class='text-center'>%y.4 %s<br />%x.1</div>"
      defaultTheme: false
      shifts:
        x: 0
        y: 20

  flot_page_likes: -> SG.Graphs.pageLikes

  flot_net_likes: -> SG.Graphs.netLikes

  flot_shares: -> SG.Graphs.shares

  flot_entries: -> SG.Graphs.entries

  flot_views: -> SG.Graphs.views

  graphPlaceholderEl: -> $('#graph_placeholder')
