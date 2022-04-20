The Get-NestedGroupMember function return all nested group members of a AD group to a hash.
    It requires a valid AD group parameter and a hash variable parameter.
    For e.g. There are 4 Groups A,B,C,D,A contains B & C, B contains C. 
    Given a $MyHash hash variable. run below ,
    Get-NestedGroupMember -GroupName A -Hash $MyHash
    $MyHash
    Key: value
    A:{B,C}
    B:{D}

- 👋 Hi, I’m @ggcjdsh
- 👀 I’m interested in PS
- 🌱 I’m currently learning PS
- 💞️ I’m looking to collaborate on PS
- 📫 How to reach me PS

<!---
ggcjdsh/ggcjdsh is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->
