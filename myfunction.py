import json
import pika
import platform
import os 
import subprocess
import datetime

exepath = (r"D:\Project\node-red\getQueue\getQueue\getQueue\bin\Debug\netcoreapp3.1\getQueue.exe")

def orch_log(task_name,status,log_desc='',log_level='info',screenshot=False, ):
    log_dict = {'Task Name':task_name,'Log Level':log_level,'Status':status,'Log':log_desc}
    message = json.dumps(log_dict)
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost',port=3672))
    channel = connection.channel()
    channel.queue_declare(queue='hello')
    channel.basic_publish(exchange='',
                        routing_key='hello',
                        body=message)
    print(" [x] Sent json object")
    connection.close()


def create_task(task_name):
    username = platform.node()+'\\'+ os.getlogin( )
    print(username)
    current_time = str(datetime.datetime.utcnow())
    task_dict = {'Task Name': task_name,'Status':"Pending",'Timespamp':current_time,"SystemName":username} 
    
    return task_dict


def task_status_update(task_details,Log,Status="Pass",Screenshot="False"):
    print(task_details)
    task_details["Status"] = Status
    task_update = {'ParentObject':task_details,"Log":Log,"Screenshot":Screenshot}
    message = json.dumps(task_update)
    x =subprocess.call(executable=exepath,args=str(task_update),shell=True)


def task_Log(task_details,Log):
    print(task_details)
    task_log = {'ParentObject':task_details,"Log":Log}
    message = json.dumps(task_log)
    x =subprocess.call(executable=exepath,args=str(task_log),shell=True)
