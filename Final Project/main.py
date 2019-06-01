import cmd
import mysql.connector
import pandas as pd

class MysqlClient:
    def __init__(self):
        self.connection = mysql.connector.connect(
            host = "localhost",
            database = "SocialNetwork",
            user = "root"
            # password = "password"
        )
        self.cursor = self.connection.cursor()
    
    def execQuery(self, query, params = None):
        self.cursor.execute(query, params)

        return self.cursor
    
    def commit(self):
        self.connection.commit()
    
    def rollback(self):
        self.connection.rollback()
    

class SocialNetworkClient(cmd.Cmd):
    intro = 'Welcome to our social Network app.   Type help or ? to list commands.\n'
    prompt = '(social network) '
    
    def __init__(self):
        super(SocialNetworkClient, self).__init__()
        self.mysql_client = MysqlClient()
        self.current_user_id = None


    def do_signup(self, arg):
        username = input("Input your user name: ")

        create_user_query = "insert into User (userName) values ('{}');".format(username)
        user_id = self.mysql_client.execQuery(create_user_query).lastrowid
        self.mysql_client.commit()

        print("User {} has been created.".format(user_id))


    def do_login(self, arg):
        username = input("Input your user name: ")

        get_user_query = "SELECT * FROM User WHERE userName = '{}';".format(username)
        result = self.mysql_client.execQuery(get_user_query).fetchall()
        self.current_user_id = result[0][0]

        if result:
            print("Login Successeed. Welcome, {}!".format(username))
        else:
            print("Login Failed. User not found.")


    def do_logout(self, arg):
        print("You have been logged out!")
        self.current_user_id = None
    

    def do_create_post(self, arg):
        topic = input("Input your post topic: ")
        content = input("Input your post content: ")

        try:
            if topic and content:
                topic_id = None
                find_top_query = "SELECT topicID FROM Topic WHERE topicName = '{}';".format(topic)
                result = self.mysql_client.execQuery(find_top_query).fetchall()
                if result:
                    topic_id = result[0][0]
                    print(topic_id)
                else:
                    # Insert the topic is topic does not exist
                    insert_topic_query = "INSERT INTO Topic VALUES (%s, %s);"
                    params = (topic_id, topic)
                    topic_id = self.mysql_client.execQuery(insert_topic_query, params).lastrowid
                    print(topic_id)
                # Insert the post with the topic
                if topic_id:
                    insert_post_query = "INSERT INTO Post (userID, textContent) VALUES (%s, %s);"
                    params = (self.current_user_id, content)
                    post_id = self.mysql_client.execQuery(insert_post_query, params).lastrowid

                    # Insert into Post_Topic 
                    if post_id:
                        insert_post_topic_query = "INSERT INTO Post_Topic VALUES (%s, %s);"
                        params = [post_id, topic_id]
                        self.mysql_client.execQuery(insert_post_topic_query, params).lastrowid

                        self.mysql_client.commit()
        except mysql.connector.Error as error :
            print("Create post failed with error: {}".format(error))
            self.mysql_client.rollback()


    def do_create_group(self, arg):
        group_name = input("Input the group name: ")
        invitee_id = input("Input the invitee user ID: ")

        if not (group_name and invitee_id):
            print("Missing input. Create group failed")
            return

        try:
            create_group_query = "insert into `Groups` (groupID, groupName, memberCount) values (NULL, '{}', 2);".format(group_name)
            group_id = self.mysql_client.execQuery(create_group_query).lastrowid

            # insert member in bulk
            insert_member_query = "insert into Group_Member (groupID, userID) values (%s, %s);"
            params = [
                (group_id, self.current_user_id), 
                (group_id, int(invitee_id))
            ]

            self.mysql_client.cursor.executemany(insert_member_query, params)
            self.mysql_client.commit()
            print("You and user {} has join group {} successfully.".format(invitee_id, group_id))
        except mysql.connector.Error as error :
            print("Create group failed with error: {}".format(error))
            self.mysql_client.rollback()


    def do_follow_group(self, arg):
        group_id = input("Input the group ID: ")

        if not group_id:
            print("Missing input. Follow group failed")
            return

        try:
            find_group_query = "select * from `Groups` where groupID = {}".format(group_id)
            result = self.mysql_client.execQuery(find_group_query).fetchall()

            if not result:
                print("Group not found!")
            else:
                # follow group if group exist
                follow_group_query = "insert into Group_Member (groupID, userID) values (%s, %s);"
                params = (group_id, self.current_user_id)

                self.mysql_client.execQuery(follow_group_query, params)
                self.mysql_client.commit()
                print("You have follow group {} successfully.".format(group_id))
        except mysql.connector.Error as error :
            print("Follow group failed with error: {}".format(error))
            self.mysql_client.rollback()


    def do_follow_topic(self, arg):
        topic_id = input("Input topic id: ")

        if not topic_id:
            print("Missing input. Follow topic failed.")
            return
        
        try:
            find_topic_query = "select * from Topic where topicID = {};".format(topic_id)
            result = self.mysql_client.execQuery(find_topic_query).fetchall()

            if not result:
                print("Topic not found!")
            else:
                follow_topic_query = "insert into Topic_Follower values (%s, %s);"
                params = (topic_id, self.current_user_id)

                self.mysql_client.execQuery(follow_topic_query, params)
                self.mysql_client.commit()
                print("You have follow topic {} successfully.".format(topic_id))
        except mysql.connector.Error as error :
            print("Follow topic failed with error: {}".format(error))
            self.mysql_client.rollback()


    def do_follow_user(self, arg):
        followee_id = input("Input the id of the user you want to follow: ")

        if not followee_id:
            print("Missing input. Follow user failed!")
            return
        
        try:
            find_followee_query = "select * from User where userID = {};".format(followee_id)
            result = self.mysql_client.execQuery(find_followee_query).fetchall()

            if not result:
                print("Followee not found")
            else:
                follow_user_query = "insert into User_Follower values (%s, %s);"
                params = (followee_id, self.current_user_id)

                self.mysql_client.execQuery(follow_user_query, params)
                self.mysql_client.commit()
                print("You have follow user {} successfully.".format(followee_id))
        except mysql.connector.Error as error :
            print("Follow user failed with error: {}".format(error))
            self.mysql_client.rollback()       


    def do_thumbs_up(self, arg):
        post_id = input("Input post id: ")

        if not post_id:
            print("Missing input. Thumbs up failed")

        try:
            find_post_query = "select * from Post where postID = {};".format(post_id)
            result = self.mysql_client.execQuery(find_post_query).fetchall()

            if not result:
                print("Post not found")
            else:
                thumbs_up_query = "update Post set thumbsUpCount = thumbsUpCount + 1 where postID = {};".format(post_id)

                self.mysql_client.execQuery(thumbs_up_query)
                self.mysql_client.commit()
                print("You have thumbed up post {} successfully.".format(post_id))
        except mysql.connector.Error as error :
            print("Thumbs up failed with error: {}".format(error))
            self.mysql_client.rollback()  
        
    
    def do_thumbs_down(self, arg):
        post_id = input("Input post id: ")

        if not post_id:
            print("Missing input. Thumbs down failed")

        try:
            find_post_query = "select * from Post where postID = {};".format(post_id)
            result = self.mysql_client.execQuery(find_post_query).fetchall()

            if not result:
                print("Post not found")
            else:
                thumbs_down_query = "update Post set thumbsDownCount = thumbsDownCount + 1 where postID = {};".format(post_id)

                self.mysql_client.execQuery(thumbs_down_query)
                self.mysql_client.commit()
                print("You have thumbed down post {} successfully.".format(post_id))
        except mysql.connector.Error as error :
            print("Thumbs down failed with error: {}".format(error))
            self.mysql_client.rollback()  


    def do_respond_to_post(self, arg):
        post_id = input("Input post id: ")
        response = input("Input response: ")

        if not (post_id and response):
            print("Missing input. Respond to post failed.")
        
        try:
            find_post_query = "select * from Post where postID = {};".format(post_id)
            result = self.mysql_client.execQuery(find_post_query).fetchall()

            if not result:
                print("Post not found")
            else:
                create_respond_post = "insert into Post (userID, textContent) values (%s, %s);"
                params = (self.current_user_id, response)

                respond_post_id = self.mysql_client.execQuery(create_respond_post, params).lastrowid

                respond_query = "insert into Post_Respond values (%s, %s);"
                params = (post_id, respond_post_id)

                self.mysql_client.execQuery(respond_query, params)
                self.mysql_client.commit()
                print("You have responded to post {} successfully.".format(post_id))
        except mysql.connector.Error as error :
            print("Respond to post failed with error: {}".format(error))
            self.mysql_client.rollback()  


    def do_get_new_posts(self, arg):
        try:
            # Get the new post from the followed topic and followed user
            get_new_post_query = '''
                SELECT postID,
                    userID,
                    topicName,
                    textContent,
                    thumbsUpCount,
                    thumbsDownCount,
                    createTime
                FROM Post
                INNER JOIN Post_Topic USING (postID)
                INNER JOIN Topic USING (topicID)
                WHERE (topicID IN
                        (SELECT topicID
                        FROM Topic_Follower
                        WHERE userID = {} )
                    OR userID IN
                        (SELECT userID
                        FROM User_Follower
                        WHERE followerID = {} ))
                AND (postID NOT IN
                        (SELECT postID
                        FROM Read_Post
                        WHERE userID = {} ));
            '''.format(self.current_user_id, self.current_user_id, self.current_user_id)
            
            result = self.mysql_client.execQuery(get_new_post_query).fetchall()

            if not result:
                print("There is no new post. You are up to date!")
            else:
                df = pd.DataFrame(result, columns=[
                    'postID',
                    'userID',
                    'topicName',
                    'textContent',
                    'thumbsUpCount',
                    'thumbsDownCount',
                    'createTime'
                ])
                print(df)

                # Record read posts
                read_posts = [(read_post[0], self.current_user_id) for read_post in result]
                insert_read_post_query = "insert into Read_Post values (%s, %s);"

                self.mysql_client.cursor.executemany(insert_read_post_query, read_posts)
                self.mysql_client.commit()
                print("Get new post successfully.")
        except mysql.connector.Error as error :
            print("Get new posts failed with error: {}".format(error))
            self.mysql_client.rollback()    


    def do_get_all_posts(self, arg):
        try:
            # Get the new post from the followed topic and followed user
            get_all_post_query = '''
                SELECT postID,
                    userID,
                    topicName,
                    textContent,
                    thumbsUpCount,
                    thumbsDownCount,
                    createTime
                FROM Post
                INNER JOIN Post_Topic USING (postID)
                INNER JOIN Topic USING (topicID)
                WHERE (topicID IN
                        (SELECT topicID
                        FROM Topic_Follower
                        WHERE userID = {} )
                    OR userID IN
                        (SELECT userID
                        FROM User_Follower
                        WHERE followerID = {} ));
            '''.format(self.current_user_id, self.current_user_id, self.current_user_id)
            
            result = self.mysql_client.execQuery(get_all_post_query).fetchall()

            df = pd.DataFrame(result, columns=[
                'postID',
                'userID',
                'topicName',
                'textContent',
                'thumbsUpCount',
                'thumbsDownCount',
                'createTime'
            ])
            print(df)
        except mysql.connector.Error as error :
            print("Get all posts failed with error: {}".format(error))
            self.mysql_client.rollback()    


    def do_get_my_posts(self, arg):
        try:
            get_my_posts_query = "select * from Post where userID = {};".format(self.current_user_id)

            result = self.mysql_client.execQuery(get_my_posts_query).fetchall()
            if not result:
                print("Empty posts.")
            else:
                my_posts = pd.DataFrame(result, columns=[
                    'postID',
                    'userID',
                    'textContent',
                    'thumbsUpCount',
                    'thumbsDownCount',
                    'createTime'
                ])
                print(my_posts)
        except mysql.connector.Error as error :
            print("Get my posts failed with error: {}".format(error))
            self.mysql_client.rollback() 


if __name__ == '__main__':
    SocialNetworkClient().cmdloop() 