var notestatus = "";
var returnchat_id = 0;
function converDatetimeFormat(date) {
    var date = new Date(date);
    var dayday = date.getDate();
    var month = date.getMonth() + 1;
    var year = date.getFullYear();
    if (month < 10) month = "0" + month;
    if (dayday < 10) dayday = "0" + dayday;
    newDate = year + '-' + month + '-' + dayday + ' ' + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
    return newDate;
}
function dropdounesearchbox() {





    if (Number($('#txtsearch').val())<=0) {
        $('#txtsearch').empty();
        $('#txtsearch').append('<option value="-1">Search By</option>');
        $('.tableheading tr th').each(function (i, e) {

            if (Number(i) > 0) {
                if ($(this).text() == "Club Name" || $(this).text() == "Role Name" || $(this).text() == "Account Name" || $(this).text() == "Category Name" || $(this).text() == "Voucher No" || $(this).text() == "Club Name" || $(this).text() == "User Name") {
                    $('#txtsearch').append('<option value="' + $(this).text() + '">' + $(this).text().toUpperCase() + '</option>');
                }
            }
        });
    }
   

    //$(".select2_single").select2({
    //    placeholder: "",
    //    allowClear: true
    //});
}
function convertdefulatnumber(date) {
    if (date == "" || date == "0" || date == "0.00" || date == "0.0") {
        return number = 0;
    } else {
        var currency = date; //it works for US-style currency strings as well
        var cur_re = /\D*(\d+|\d.*?\d)(?:\D+(\d{2}))?\D*$/;
        var parts = cur_re.exec(currency);
        var number = parseFloat(parts[1].replace(/,/g, "") + '.' + (parts[2] ? parts[2] : '00'));
        return number;
    }

}
function dateFormatChangedmyWithMonthName(date) {
    var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    var dateAr1 = date.split('-');
    return dateAr1[2] + '-' + monthNames[dateAr1[1] - 1] + '-' + dateAr1[0];
}
function convertdefulatnumber(date) {
    if (date == "" || date == "0" || date == "0.00" || date == "0.0") {
        return number = 0;
    } else {
        var currency = date; //it works for US-style currency strings as well
        var cur_re = /\D*(\d+|\d.*?\d)(?:\D+(\d{2}))?\D*$/;
        var parts = cur_re.exec(currency);
        var number = parseFloat(parts[1].replace(/,/g, "") + '.' + (parts[2] ? parts[2] : '00'));
        return number;
    }

}
function signOut() {
    localStorage.clear();
    sessionStorage.clear();
    window.location.href = "/Default.aspx";
}



function generatepagination(paginationjsondata, divid, tablename, functionname, datefrom, dateto) {

    $(paginationjsondata).each(function (index, infostd) {



        var startcountno = (Number(infostd.pageSize) * Number(infostd.currentPage)) - Number(infostd.pageSize) + 1;
        var endcountno = Number(infostd.pageSize) * Number(infostd.currentPage);


        $('#' + divid + ' .clstableshowrowsstart').html(startcountno);


        if (Number(infostd.totalCount) < Number(endcountno)) {
            endcountno = infostd.totalCount
        }

        $('#' + divid + ' .clstableshowrowsend').html(endcountno);


        $('#' + divid + ' .clstableshowrowstotal').html(infostd.totalCount);


        $('#' + divid + ' .pagination').empty();
        //pagination back button start

        if (infostd.previousPage == "No") {
            $('#' + divid + ' .pagination').append('<li class="1 ' + divid + ' ' + functionname + ' ' + datefrom + ' ' + dateto + ' paginate_button 0 page-item previous disabled" id="datatable_previous"><a href="#" aria-controls="datatable" data-dt-idx="0" tabindex="0" class="page-link">Previous</a></li>');
        }
        else {
            $('#' + divid + ' .pagination').append('<li class="' + (Number(infostd.currentPage) - 1) + ' ' + divid + ' ' + functionname + ' ' + datefrom + ' ' + dateto + ' paginate_button ' + (Number(infostd.currentPage) - 1) + ' page-item previous" id="datatable_previous"><a href="#" aria-controls="datatable" data-dt-idx="0" tabindex="0" class="page-link">Previous</a></li>');
        }
        //pagination back button end

        //pagination numbers start

        var paginationloopstart = 1

        var paginationloopend = 10;

        if (Number(infostd.currentPage) >= 10) {

            paginationloopend = Number(infostd.currentPage) + 1;

            paginationloopstart = Number(paginationloopend) - 10;
        }


        if (Number(infostd.totalPages) < Number(paginationloopend)) {
            paginationloopend = infostd.totalPages
        }



        for (var i = Number(paginationloopstart); i <= Number(paginationloopend); i++) {


            if (Number(i) == Number(infostd.currentPage)) {
                $('#' + divid + ' .pagination').append('<li class="' + i + ' ' + divid + ' ' + functionname + ' ' + datefrom + ' ' + dateto + ' paginate_button page-item active"><a href="#" aria-controls="datatable" data-dt-idx="' + i + '" tabindex="0" class="page-link">' + i + '</a></li>');
            }
            else {
                $('#' + divid + ' .pagination').append('<li class="' + i + ' ' + divid + ' ' + functionname + ' ' + datefrom + ' ' + dateto + ' paginate_button page-item"><a href="#" aria-controls="datatable" data-dt-idx="' + i + '" tabindex="0" class="page-link">' + i + '</a></li>');
            }

        }
        //pagination numbers end



        //pagination back button start

        if (infostd.nextPage == "Yes") {
            $('#' + divid + ' .pagination').append('<li class="' + (Number(infostd.currentPage) + 1) + ' ' + divid + ' ' + functionname + ' ' + datefrom + ' ' + dateto + ' paginate_button page-item next" id="datatable_next"><a href="#" aria-controls="datatable" data-dt-idx="1" tabindex="0" class="page-link">Next</a></li>');

        }
        else {
            $('#' + divid + ' .pagination').append('<li class="' + Number(infostd.currentPage) + ' ' + divid + ' ' + functionname + ' ' + datefrom + ' ' + dateto + ' paginate_button 0 page-item next disabled" id="datatable_next"><a href="#" aria-controls="datatable" data-dt-idx="7" tabindex="0" class="page-link">Next</a></li>');
        }
        //pagination next button end


        //pagination table rows numbers start

        $('#' + tablename + ' tr').each(function (i) {
            $(this).find('td:nth-child(1)').html(startcountno)
            startcountno++
        });
        //pagination table rows numbers end

    });
}

function converDatetimeFormat(date) {
    var date = new Date(date);
    var dayday = date.getDate();
    var month = date.getMonth() + 1;
    var year = date.getFullYear();
    if (month < 10) month = "0" + month;
    if (dayday < 10) dayday = "0" + dayday;
    newDate = year + '-' + month + '-' + dayday;
    return newDate;
}
function RemoveDatetimeFormat(date) {
    var date = converDatetimeFormat(date);
    return date.split(' ')[0];
}
function formatAMPM(date) {
    var strTime = "";
    if (date == "" || date == "null" || date == null || date == "undefined") {
        strTime = "";
    }
    else {
        date = new Date(date);
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        strTime = hours + ':' + minutes + ' ' + ampm;
    }
    return strTime;
}


function gettime(date) {
    let date_ob = new Date(date);

    // adjust 0 before single digit date

    // current month

    // current year

    // current hours
    let hours = date_ob.getHours();

    // current minutes
    let minutes = date_ob.getMinutes();

    // current seconds
    let seconds = "00";
    if (hours <= 9) {
        hours = "0" + hours;
    }
    if (minutes <= 9) {
        minutes = "0" + minutes;
    }

    // prints date & time in YYYY-MM-DD HH:MM:SS format
    return (hours + ":" + minutes + ":" + seconds);
}