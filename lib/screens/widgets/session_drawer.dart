import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../page/setting_page.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session_model.dart';

class SessionDrawer extends StatelessWidget {
  const SessionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final sessions = provider.sessions;

    final projectSessions =
    sessions.where((s) => s.projectName != null).toList();

    final normalSessions =
    sessions.where((s) => s.projectName == null).toList();

    final Map<String, List<ChatSession>> groupedProjects = {};
    for (var session in projectSessions) {
      groupedProjects
          .putIfAbsent(session.projectName!, () => [])
          .add(session);
    }

    return Drawer(
      backgroundColor: const Color(0xFF020617),
      child: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Chat Sessions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    borderRadius:
                    BorderRadius.circular(10),
                    onTap: () {
                      _showCreateProjectDialog(
                          context, provider);
                    },
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF1F2937),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.create_new_folder,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Add Project",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (groupedProjects.isNotEmpty)
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8),
                      child: Text(
                        "Projects",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                  ...groupedProjects.entries
                      .map((entry) {
                    final projectName =
                        entry.key;
                    final projectChats =
                        entry.value;

                    return ExpansionTile(
                      collapsedIconColor:
                      Colors.grey,
                      iconColor: Colors.grey,
                      title: Text(
                        projectName,
                        style: const TextStyle(
                            color:
                            Colors.white),
                      ),
                      leading: const Icon(
                        Icons.folder,
                       // color: Colors.grey,
                      ),
                      children: projectChats
                          .map((session) =>
                          _buildSessionTile(
                              context,
                              provider,
                              session))
                          .toList(),
                    );
                  }),

                  if (normalSessions.isNotEmpty)
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8),
                      child: Text(
                        "All Chats",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                  ...normalSessions.map(
                        (session) =>
                        _buildSessionTile(
                            context,
                            provider,
                            session),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingPage()));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.settings,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 3,),
                        Text("Settings",
                          style: TextStyle(color:Colors.grey,fontWeight: FontWeight.bold,fontSize: 18),
                        ),
                      ],
                    ),
                  ),SizedBox(height: 5,),
                  Center(child: InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Logout",style: TextStyle(color: Colors.red,fontSize:18,fontWeight: FontWeight.bold),),
                        SizedBox(width: 3,),
                        Icon(Icons.logout,color: Colors.grey,)
                      ],
                    ),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(
      BuildContext context,
      ChatProvider provider,
      ChatSession session,
      ) {
    final isActive =
        session.sessionId ==
            provider.currentSession?.sessionId;

    final isProjectChat =
        session.projectName != null;

    return Container(
      margin:
      const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF1F2937)
            : Colors.transparent,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
            horizontal: 12),
        leading: Icon(
          isProjectChat
              ? Icons.folder_open
              : Icons.chat_bubble_outline,
          color: isActive
              ? Colors.grey
              : (isProjectChat
              ? Colors.grey
              : Colors.white70),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white),
        ),
        trailing:
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white70,
          ),
        //  color: const Color(0xFF1F2937),
          onSelected:
              (value) async {
            if (value == "delete") {
              provider.deleteSession(
                  session.sessionId);
            } else if (value ==
                "share") {
              provider
                  .shareSession(
                  session);
            } else if (value ==
                "project") {
              _showProjectDialog(
                  context,
                  provider,
                  session);
            }
          },
          itemBuilder:
              (context) => const [
            PopupMenuItem(
              value: "delete",
              child:
              Text("Delete"),
            ),
            PopupMenuItem(
              value: "share",
              child: Text("Share"),
            ),
            PopupMenuItem(
              value: "project",
              child: Text(
                  "Add to Project"),
            ),
          ],
        ),
        onTap: () {
          provider.switchSession(
              session.sessionId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCreateProjectDialog(
      BuildContext context,
      ChatProvider provider,
      ) {
    final controller =
    TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        const Color(0xFF1F2937),
        title: const Text(
          "Create New Project",
          style: TextStyle(
              color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(
              color: Colors.white),
          decoration:
          const InputDecoration(
            hintText:
            "Project name",
            hintStyle:
            TextStyle(
                color:
                Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color:
                  Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name =
              controller.text
                  .trim();
              if (name
                  .isEmpty) return;

              provider
                  .createEmptyProject(
                  name);

              Navigator.pop(
                  context);
            },
            child:
            const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showProjectDialog(
      BuildContext context,
      ChatProvider provider,
      ChatSession session,
      ) {
    final controller =
    TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
        const Color(0xFF1F2937),
        title: const Text(
          "Enter Project Name",
          style: TextStyle(
              color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(
              color: Colors.white),
          decoration:
          const InputDecoration(
            hintText:
            "Project name",
            hintStyle:
            TextStyle(
                color:
                Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color:
                  Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller
                  .text
                  .trim()
                  .isEmpty) return;

              provider
                  .assignProject(
                session
                    .sessionId,
                controller
                    .text
                    .trim(),
              );

              Navigator.pop(
                  context);
            },
            child:
            const Text("Save"),
          ),
        ],
      ),
    );
  }
}
