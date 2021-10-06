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
operate=$CDC_TEST/operate
supplement=$CDC_TEST/supp
thread=$CDC_TEST/thread

api_cnt=23
insert_cnt=4
delete_cnt=6
update_cnt=6
table_cnt=1
index_cnt=1
trigger_cnt=1
serial_cnt=1
view_cnt=1
procedure_cnt=1
operate_cnt=7
supp_cnt=20
thread_cnt=5

#rm -rf CUBRID-11.1.0* &&
#echo -e "y\ny\ny\n" | sh ~/cdc-build/*.sh && 
#sh /home/joohok/.cubrid.sh

#cd $api

#for [] 
#api0#.sh


#for ((i=1;i<=${api_cnt};i++))
#do
#  if [[ $i -lt 10 ]]
#  then 
#    cd $api/api0${i}
#    sh api0${i}.sh
#  else
#    cd $api/api${i}
#    sh api${i}.sh
#  fi 
#done

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
  cd $table
  sh table01.sh
done

for ((i=1;i<=${index_cnt};i++))
do
  cd $index
  sh index01.sh
done

for ((i=1;i<=${view_cnt};i++))
do
  cd $view
  sh view01.sh
done

for ((i=1;i<=${serial_cnt};i++))
do
  cd $serial
  sh serial01.sh
done

for ((i=1;i<=${trigger_cnt};i++))
do
  cd $trigger
  sh trigger04.sh
done

for ((i=1;i<=${procedure_cnt};i++))
do
  cd $procedure
  sh procedure02.sh
done

for ((i=1;i<=${operate_cnt};i++))
do
  cd $operate/oper0${i}
  sh oper0${i}.sh
done

for ((i=1;i<=${thread_cnt};i++))
do
  cd $thread/thread0${i}
  sh thread0${i}.sh
done

if [ `grep "FAIL" ${CDC_TEST}/result |wc -l` -eq 0 ]
then 
    echo 'PASS all'
else
    echo 'FAILED test'
fi

