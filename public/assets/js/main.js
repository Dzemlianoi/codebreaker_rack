var App = {

    init: function () {
        App.disabling();
        $('.next-options').click(this.submitName);
    },

    disabling: function () {
        $('.next-options').off('click');
    },

    submitName:function(){
        if (App.checkName() == 'ok'){
            $('.name-group').fadeOut( "slow", function() {
                $('.diff-group').fadeIn('slow',function(){});
            });
        }
    },

    checkName: function(){
        var input = $('#name').val();
        switch (true){
            case input.length < 3 || input.length > 20:
                var message = 'Name should consists from 3-20 letters';
                break;
            case !/^[A-Za-z0-9]*$/.test(input):
                var message = 'Name should consists from letters or numbers';
                break;
        }
        return typeof(message) == undefined ? message : 'ok';
    }

};

App.init();