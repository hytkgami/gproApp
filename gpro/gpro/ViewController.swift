//
//  ViewController.swift
//  gpro
//
//  Created by Ryojiro Kobayashi on 8/28/16.
//  Copyright © 2016 Ryojiro Kobayashi. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import APIKit

class ViewController: UIViewController {

    @IBAction func backToLP (segue: UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    @IBAction func tapView(sender: AnyObject) {
        self.view.endEditing(true)
    }

    @IBOutlet weak var in_name: UITextField!
    @IBOutlet weak var in_email: UITextField!
    @IBOutlet weak var in_password: UITextField!
    @IBOutlet weak var in_address: UITextField!
    @IBOutlet weak var in_birthday: UITextField!
    
    @IBAction func signUp(sender: AnyObject) {
        let email = AWSCognitoIdentityUserAttributeType()
        email.name = "email"
        email.value = in_email.text
        let name = AWSCognitoIdentityUserAttributeType()
        name.name = "name"
        name.value = NSUUID().UUIDString
        let nickname = AWSCognitoIdentityUserAttributeType()
        nickname.name = "nickname"
        nickname.value = in_name.text
        let picture = AWSCognitoIdentityUserAttributeType()
        picture.name = "picture"
        picture.value = "https://aws/s3/url"
        let address = AWSCognitoIdentityUserAttributeType()
        address.name = "address"
        address.value = in_address.text
        let birthday = AWSCognitoIdentityUserAttributeType()
        birthday.name = "custom:birthday"
        birthday.value = in_birthday.text
        
        NSUserDefaults.standardUserDefaults().setValue(name.value, forKey: "myname")
        
        // AWS Cognitoを使用したユーザー登録を行うには、ユニークなUsername（ユーザーID）を設定する必要があります。
        // この例では'hoge'です。
        // Usernameは登録の確認で使用するので、アプリが落ちても消えない場所に保存しておく必要があります。
        // 具体例として、UUIDをUsernameとして使用しNSUserDefaultsに保存など。
        // Usernameはユーザーに知られてはいけないので注意してください。
        //
        // 実際に使用するとき、アイコン画像はS3に保存する必要があるのでS3にアップロードし、
        // そのURLを'picture'に設定してください。
        // S3については今後追加します。
        let pool = AWSCognitoIdentityUserPool(forKey: "AmazonCognitoIdentityProvider")
        pool.signUp(name.value!, password: in_password.text!, userAttributes: [email, name, nickname, picture, address, birthday], validationData: nil).continueWithBlock { task in
            if task.error != nil {
                print("---error---")
                print(task.error)
                return nil
            }
            let user = task.result as? AWSCognitoIdentityUser
            print(user)
            return nil
        }
    }
    
    @IBOutlet weak var confirmNum: UITextField!
    @IBAction func Confirm(sender: AnyObject) {
        // Cognitoでは会員登録にメールアドレスまたは電話番号の確認をとることができます。
        // 今回は登録したメールアドレスに確認番号が送られてくるので、それを入力します。
        // 確認するときにUsername（エイリアスはダメ）が必要になります。
        let pool = AWSCognitoIdentityUserPool(forKey: "AmazonCognitoIdentityProvider")
        let name = NSUserDefaults.standardUserDefaults().stringForKey("myname")
        let user = pool.getUser(name!)
        user.confirmSignUp(confirmNum.text!).continueWithBlock { task in
            if task.error != nil {
                print("---error---")
                print(task.error)
                return nil
            }
            print("----ok----")
            print(task.result)
            return nil
        }
        //原因不明。複数回呼び出されている？
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("login") as! ViewController
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var login_email: UITextField!
    @IBOutlet weak var login_password: UITextField!
    @IBAction func SignIn(sender: AnyObject) {
        // ログインにはUsernameとパスワードが必要になりますが、Usernameはユーザーに公開してはいけないので、
        // Usernameのエイリアスとして設定したメールアドレスとパスワードでログインします。
        let pool = AWSCognitoIdentityUserPool(forKey: "AmazonCognitoIdentityProvider")
        let user = pool.getUser()
        //メールアドレスでログイン出来ないため、NSuserDefaultでログインしている
        user.getSession(NSUserDefaults.standardUserDefaults().stringForKey("myname")!, password: login_password.text!, validationData: nil, scopes: nil).continueWithBlock { task in
            if task.error != nil {
                print("---error---")
                print(task.error)
                return nil
            }
            
            let session = task.result as! AWSCognitoIdentityUserSession
            print(session.accessToken?.tokenString)
            print(user.signedIn)
            return nil
        }
        let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("guestTop") as! ViewController
        self.presentViewController( targetViewController, animated: true, completion: nil)
    }
}