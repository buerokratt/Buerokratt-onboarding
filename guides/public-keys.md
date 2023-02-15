### About
#### Tutorial on how to create and find SSH key 

##### SSH key generating: Linux and MacOSX
##### Note: Generating your SSH key, do not use `sudo` 

##### Create the key
Navigate to your SSH folder under your home folder
```
cd /home/username/.ssh  
```
Here generate your SSH key  

```
ssh-keygen -t rsa -C "your_email@example.com"
```
Check the content of he `.ssh` folder
```
ls -la
```
You should see something like this:  
![image](https://user-images.githubusercontent.com/101868197/219118883-a6bbdc74-11c3-4655-9e78-48a56773e586.png)


### File named id_rsa contains your private key, it is unique and if you delete it or lose it, you have to re-create your ssh key

##### Check your generated key
```
cat id_rsa.pub
```
