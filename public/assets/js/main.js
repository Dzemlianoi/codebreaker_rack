var App = {

    error_message:'',

    init: function () {
        App.disabling();
        $('.next-options').click(this.checkOptions);
        $('.form-options').submit(this.submitOptions);
    },

    disabling: function () {
        $('.next-options').off('click');
    },

    checkOptions:function(){
        if (App.checkName()) {
            App.normaliseInput();
            if ($('.name-group').css('display') != 'none'){
                $('.name-group').fadeOut("slow", function () {
                    $('.diff-group').fadeIn('slow', function () {

                        return false;
                    });
                });
            }else{
                return true;
            }
        }else{
            App.wrongInput();
        }
    },

    checkName: function(){
        var input = $('#name').val();
        switch (true){
            case input.length < 3 || input.length > 20:
                App.error_message = 'Name should consists from 3-20 letters';
                break;
            case !/^[A-Za-z0-9]*$/.test(input):
                App.error_message = 'Name should consists from letters or numbers';
                break;
            default:
                App.error_message = '';
        }

        return this.error_message == '' ;
    },

    wrongInput: function(){
        $('.name-group').addClass('has-error has-danger');
        $('.help-block').text(App.error_message)
    },

    normaliseInput:function(){
        $('.name-group').removeClass('has-error has-danger');
        $('.help-block').text('');

    },

    submitOptions: function(event){
        event.preventDefault();
        if (App.checkOptions()){
            $(this).unbind('submit').submit();
        }

    }

};

App.init();