api=$CDC_TEST/api
insert=$CDC_TEST/dml/insert
delete=$CDC_TEST/dml/delete
update=$CDC_TEST/dml/update
ddl=ddl/
table=$CDC_TEST/ddl/table
index=$CDC_TEST/ddl/index
view=$CDC_TEST/ddl/view
serial=$CDC_TEST/ddl/serial
trigger=$CDC_TEST/ddl/trigger
function=$CDC_TEST/ddl/procedure
proceure=$CDC_TEST/ddl/procedure

api_cnt=6
insert_cnt=5
delete_cnt=0
update_cnt=6
table_cnt=5
index_cnt=3
trigger_cnt=4
serial_cnt=5
pocedure_cnt=2

rm -rf CUBRID-11.1.0* &&
echo -e "y\ny\ny\n" | sh ~/cdc-build/*.sh && 
sh /home/joohok/.cubrid.sh

cd $api

#for [] 
#api0#.sh
for ((i=1;i<=${api_cnt};i++))
do
  cd $api/api0${i}
  sh api0${i}.sh
done

for ((i=1;i<=${insert_cnt};i++))
do
  cd $insert/insert0${i}
  sh insert0${i}.sh
done

for ((i=1;i<=${delete_cnt};i++))
do
  cd $delete/delete0${i}
  sh delete0${i}.sh
done

for ((i=1;i<=${update_cnt};i++))
do
  cd $update/update0${i}
  sh update0${i}.sh
done

for ((i=1;i<=${table_cnt};i++))
do
  cd $table/table0${i}
  sh table0${i}.sh
done

for ((i=1;i<=${index_cnt};i++))
do
  cd $index/index0${i}
  sh index0${i}.sh
done

for ((i=1;i<=${view_cnt};i++))
do
  cd $view/view0${i}
  sh view0${i}.sh
done

for ((i=1;i<=${serial_cnt};i++))
do
  cd $serial/serial0${i}
  sh serial0${i}.sh
done

for ((i=1;i<=${trigger_cnt};i++))
do
  cd $trigger/trigger0${i}
  sh trigger0${i}.sh
done

for ((i=1;i<=${procedure_cnt};i++))
do
  cd $procedure/procedure0${i}
  sh procedure0${i}.sh
done

if [ `grep "FAIL" ${CDC_TEST}/result |wc -l` -eq 0 ]
then 
    echo 'PASS all'
else
    echo 'FAILED test'
fi

