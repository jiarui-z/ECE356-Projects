# Social Network CLI

The application is a simulation of a social network system written in Python with MySQL database as storage.
The user interface is command-line based and it suppors mulitple instructions to simulate a social network.

## Getting Started
### Prerequisites
- `Python3`
- `MySQL8.0`
- `mysql-connector`
- `pandas`

### Note
The version of python has to be Python3, the program will not run under Python2. Check if pip has been installed for Python3 and you will need to pip install mysql-connector and pip install pandas.

### Files
1. The file main.py is the python execution file which is the main program for the social network project
2. The file SocialNetwork.sql is our database with some sample data in it.
3. For ER model and the report on tables relationship report, please consult SocialNetwork.pdf.

## How to Run
1. Source the database into your own SQL server first before you start.
2. Noice the def's in main.py, those are the functions for the social network system.
3. Run the program using the following command: python3 main.py and then in ipython interface,      enter the function name after 'do'.

## Functions Usage
- `signup`
    - Sign a user up with user name and the system will automatically assign an ID, as a unique identifier for the user.
    - Username is already set as primary key so that if you signup with a duplicate username, you will get duplicate error.

- `login`
    - The system will ask for your username, so you use your username to login. A sample user name is "Frank123".
    - If the entered username is in the database, the system will prompt with successful message
    - If the entered userame is not in the databse, it will report failure.

- `logout`
    - This function will simply log out the current user from the system.
    - This operation will set the current user ID to NULL.

- `create_post`
    - This function takes 2 inputs: topic and content.
    - If a topic name is not exist, a new topic will be created under this name. This operation will insert an entry into Post table.
    - A new post will be created with provided content and will be assigned under the topic name. This operation will also insert an entry into Post_Topic table to link the post and the topic.
    - If the topic exists, then it will not create new topic but still link the post to a topic.

- `create_group`
    - This function takes 2 inputs: the group name and invitee user ID
    - Error handling: If the input is invalid, catch it.
    - If all the input checks out, the program will insert a new entry into table Groups and the system will assign a new groupID to it.
    - It will also insert a new entry into table Group_Member to link the group and its member.

- `follow_group`
    - This function takes 1 input: the groupID.
    - Error handling: if the input is invalid, catch it.
    - If the group is not found, the program will report an error.
    - This operation will insert a new entry into Group_Member to link the group with the current user so that the user can receive updates from the group.
    - Success message will be displayed if successfully followed the group.

- `follow_topic`
    - This function takes 1 input: the topicID.
    - The program will report error if the topic ID is not exist.
    - This operation will insert a new entry into Topic_Follower table to link the topic to the current user.
    - The current user will receive update from the followed topic.
    - The program will report success after succcessfully followed the topic.

- `follow_user`
    - This function takes 1 input: the userID you want to follow.
    - Error handling: If the input is invalid, catch it.
    - The program will report error if the userID entered is not exist.
    - This operation will insert a new entry into User_Follower table to link the current user with the entered user.
    - The current user will then receive updates from the inputed user.
    - The program will report success after successfully followed a user.

- `thumbs_up`
    - This function takes 1 input: the postID you want to thumbs up.
    - Error handling: If the input is invalid, catch it.
    - The program will report error if the postID entered is not exist.
    - This operation will increment the thumbsUpCount for the specific post by 1.
    - The program will report success after successfully thums up.

- `thumbs_down`
    - This function takes 1 input: the postID you want to thumbs down.
    - Error handling: If the input is invalid, catch it.
    - The program will report error if the postID entered is not exist.
    - This operation will increment the thumbsDownCount for the specific post by 1.
    - The program will report success after successfully thums down.

- `respond_to_post`
    - This function takes 2 inputs: the postID and the response content.
    - Error handling: If the input is invalid, catch it.
    - The program will report error if the postID entered is not exist.
    - This operation will create a new post with its contents, and will instert a new entry to Post table, with a system assigned postID.
    - This operation will also link the new post to the post that it wants to response, which is inserting a new entry into Post_Respond table.
    - The program will report success after successfully responede a post.

- `get_new_posts`
    - This function will display new posts that has been added by people and topic that the current user is following since their last read from those people and topics.
    - If there are no new post from the followed group or user, the program will report the current user is up to date.
    - If there are new posts, the program will display their information.
    - The program will insert new entries to Read_Post to mark the posts displayed this time as read by the current user, so they will not be new posts anymore.
    - The program will report success after displaying the new post information.

- `get_all_posts`
    - This function will display the information of all posts that current user follows.

- `get_my_posts`
    - This function will display the information of all posts that is posted by the current user.
    - If the user is not having any posts, the program will report empty.
