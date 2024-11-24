# Ferramenta de criação/atualização de cópias de segurança em Bash

Este projeto contém um conjunto de scripts Bash desenvolvidos para realizar operações de backup de diretórios e arquivos, com suporte a opções avançadas de exclusão, validação e relatório.

---

## Estrutura do Projeto

### Scripts Incluídos

#### `backup_files.sh`
- Realiza o backup de arquivos em um diretório que não contém subdiretórios.
- Atualiza apenas os arquivos cuja data de modificação seja posterior à do backup correspondente.
- **Opção Suportada**:
  - `-c`: Exibe os comandos que seriam executados, sem alterar o conteúdo da diretoria de backup.

```bash
./backup_files.sh [-c] dir_trabalho dir_backup
```

---

#### `backup.sh`
- Expande o script anterior para suportar diretórios com subdiretórios e opções adicionais.
- Pode ser executado recursivamente para processar subdiretórios.
- **Opções Suportadas**:
  - `-c`: Modo de simulação (exibe os comandos, mas não executa).
  - `-b tfile`: Define um arquivo de texto contendo uma lista de arquivos/diretórios a serem excluídos do backup.
  - `-r regexpr`: Copia apenas os arquivos que correspondem à expressão regular fornecida.

```bash
./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup
```

---

#### `backup_summary.sh`
- Expande o script `backup.sh` para incluir um sumário ao final de cada execução, mostrando:
  - Número de erros.
  - Warnings.
  - Arquivos atualizados.
  - Arquivos copiados.
  - Arquivos apagados.

```bash
./backup_summary.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup
```
---

#### `backup_check.sh`
- Verifica se o conteúdo dos arquivos na diretoria de backup é idêntico ao dos arquivos correspondentes na diretoria de trabalho.
- Usa o comando `md5sum` para comparar os conteúdos.
- Não realiza cópias nem verifica novos arquivos.


```bash
./backup_check.sh dir_trabalho dir_backup
```

---
