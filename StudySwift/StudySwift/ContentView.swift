import SwiftUI

let LightBlue = Color(red: 176.0/255.0, green: 224.0/255.0, blue: 230.0/255.0, opacity: 1.0)
let DarkBlue = Color(red: 24.0/255.0, green: 24.0/255.0, blue: 35.0/255.0, opacity: 1.0)
let RobinBlue = Color(red: 93.0/255.0, green: 204.0/255.0, blue: 197.0/255.0, opacity: 1.0)

struct ContentView: View {
        @State var email: String = ""
        @State var password: String = ""
         
        @State var authenticationDidFail: Bool = false
         
        var body: some View {
            NavigationView {
                VStack {
                    Image("LandingLogo")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 75)
                     
                    Text("Email").foregroundColor(Color.white).multilineTextAlignment(.leading)
                    TextField("you@your-domain.com", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .shadow(radius: 5)
                    
                    Text("Password").foregroundColor(Color.white).multilineTextAlignment(.leading)
                    SecureField("*********", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .shadow(radius: 5)
                    
                    
                     
                    Button(action: {}) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(LightBlue)
                            .cornerRadius(15.0)
                            .shadow(radius: 5)
                    }
                    
                     
                   VStack {
                       Text("New user?").foregroundColor(Color.white)
                       NavigationLink(destination: ContentViewRegister().navigationBarBackButtonHidden(true)) {
                           Text("Sign up here.").foregroundColor(LightBlue)
                       }
                    }
                   .padding()
                }
                .padding()
                .background(DarkBlue)
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ContentViewRegister : View {
     
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
 
    
    var body: some View {
        NavigationView {
            VStack {
                Image("LandingLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 75)
                 
                Text("Email").foregroundColor(Color.white).multilineTextAlignment(.leading)
                TextField("you@your-domain.com", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .shadow(radius: 5)
                
                Text("Password").foregroundColor(Color.white).multilineTextAlignment(.leading)
                SecureField("*********", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .shadow(radius: 5)
                
                Text("Confirm Password").foregroundColor(Color.white).multilineTextAlignment(.leading)
                SecureField("*********", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .shadow(radius: 5)
                
                Button(action: {}) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(LightBlue)
                        .cornerRadius(15.0)
                        .shadow(radius: 5)
                }
                
                 
               VStack {
                   Text("Existing user?").foregroundColor(Color.white)
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        Text("Login here.").foregroundColor(LightBlue)
                    }
                }
               .padding()
            }
            .padding()
            .background(DarkBlue)
        }
    }
}
