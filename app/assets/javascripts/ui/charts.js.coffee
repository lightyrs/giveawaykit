SG.UI.Charts =

  initialize: ->
    @attachSparklines() if @sparklineEls().length
    @attachEasyPieCharts() if @easyPieChartEls().length

  attachSparklines: ->
    sr = undefined
    sparkline = ($re) =>
      @sparklineEls().each ->
        $data = $(this).data()
        return  if $re and not $data.resize
        ($data.type is 'pie') and $data.sliceColors and ($data.sliceColors = eval($data.sliceColors))
        ($data.type is 'pie') and $data.tooltipValueLookups and ($data.tooltipValueLookups = eval($data.tooltipValueLookups))
        ($data.type is 'bar') and $data.stackedBarColor and ($data.stackedBarColor = eval($data.stackedBarColor))
        $data.valueSpots = '0:': $data.spotColor
        $(this).sparkline 'html', $data

    $(window).resize (e) ->
      clearTimeout sr
      sr = setTimeout(-> sparkline true, 500)

    sparkline false

  attachEasyPieCharts: ->
    @easyPieChartEls().each ->
      $this = $(this)
      $data = $this.data()
      $step = $this.find('.step')
      $target_value = parseInt($($data.target).text())
      $value = 0
      $data.barColor or ($data.barColor = ($percent) ->
        $percent /= 100
        "rgb(#{Math.round(200 * $percent)}, 200, #{Math.round(200 * (1 - $percent))})"
      )

      $data.onStep = (value) ->
        $value = value
        $step.text parseInt(value)
        $data.target and $($data.target).text(parseInt(value) + $target_value)

      $data.onStop = ->
        $target_value = parseInt($($data.target).text())
        $data.update and setTimeout(->
          $this.data("easyPieChart").update 100 - $value
        , $data.update)

      $(this).easyPieChart $data

  sparklineEls: -> $('.sparkline')

  easyPieChartEls: -> $('.easypiechart')