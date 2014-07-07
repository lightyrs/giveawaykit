$(function() {

    // sparkline
    var sr, sparkline = function($re) {
            $(".sparkline").each(function() {
                var $data = $(this).data();
                if ($re && !$data.resize) return;
                ($data.type == 'pie') && $data.sliceColors && ($data.sliceColors = eval($data.sliceColors));
                ($data.type == 'pie') && $data.tooltipValueLookups && ($data.tooltipValueLookups = eval($data.tooltipValueLookups));
                ($data.type == 'bar') && $data.stackedBarColor && ($data.stackedBarColor = eval($data.stackedBarColor));
                $data.valueSpots = {
                    '0:': $data.spotColor
                };
                $(this).sparkline('html', $data);
            });
        };
    $(window).resize(function(e) {
        clearTimeout(sr);
        sr = setTimeout(function() {
            sparkline(true)
        }, 500);
    });
    sparkline(false);


    // easypie
    $('.easypiechart').each(function() {
        var $this = $(this),
            $data = $this.data(),
            $step = $this.find('.step'),
            $target_value = parseInt($($data.target).text()),
            $value = 0;
        $data.barColor || ($data.barColor = function($percent) {
            $percent /= 100;
            return "rgb(" + Math.round(200 * $percent) + ", 200, " + Math.round(200 * (1 - $percent)) + ")";
        });
        $data.onStep = function(value) {
            $value = value;
            $step.text(parseInt(value));
            $data.target && $($data.target).text(parseInt(value) + $target_value);
        }
        $data.onStop = function() {
            $target_value = parseInt($($data.target).text());
            $data.update && setTimeout(function() {
                $this.data('easyPieChart').update(100 - $value);
            }, $data.update);
        }
        $(this).easyPieChart($data);
    });

    // slim-scroll
    $('.no-touch .slim-scroll').each(function() {
        var $self = $(this),
            $data = $self.data(),
            $slimResize;
        $self.slimScroll($data);
        $(window).resize(function(e) {
            clearTimeout($slimResize);
            $slimResize = setTimeout(function() {
                $self.slimScroll($data);
            }, 500);
        });
    });
});
