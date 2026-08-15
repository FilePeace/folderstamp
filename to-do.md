# To-do

Uma lista organizada dos próximos feitiços técnicos do `folderstamp`.

## Próximas prioridades

- [ ] Adicionar flag `--help` com exemplos de uso para `display`, `save`, `--recursive` e futuras opções.
- [ ] Implementar flag `--hash` para controlar quando o CID/IPFS hash deve ser calculado.
- [ ] Criar rotação automática de `.folderstamp`, gerando `.folderstamp1`, `.folderstamp2` etc. quando o arquivo já existir.
- [ ] Adicionar suporte a `.folderstampignore`, seguindo uma lógica parecida com `.gitignore`.
- [ ] Ignorar itens internos por padrão, como `.git/` e o próprio `.folderstamp`, especialmente no modo recursivo.
- [ ] Registrar a data/hora exata no fim de cada `.folderstamp`.
- [ ] Adicionar opção para registrar o número do bloco Ethereum mais recente no momento do stamp.

## Modos de listagem

- [ ] Criar modo simples `.ls`, com rotação `.ls1`, `.ls2` etc.
- [ ] Criar `.folderstamp.listed` para evitar listar novamente arquivos já snapshotados anteriormente.
- [ ] Avaliar integração futura com uma biblioteca de nomes incrementais/untitled para evitar sobrescrever arquivos.

## Desktop e ambiente gráfico

- [ ] Quando o stamp for feito no Desktop, detectar o ambiente gráfico quando possível.
- [ ] Em Cinnamon, registrar o wallpaper atual com:
  ```sh
  gsettings get org.cinnamon.desktop.background picture-uri | tr -d "'"
  ```
- [ ] Pesquisar como registrar posições e ícones de itens no Desktop por ambiente gráfico.
- [ ] Fazer fallback silencioso quando não houver desktop environment detectado.

## Recursividade e escopo

- [ ] No modo recursivo, registrar também metadados das pastas, não apenas dos arquivos.
- [ ] Adicionar opção para limitar profundidade de recursão.
- [ ] Adicionar opção para escolher um número customizado para `.folderstamp`, recusando números já existentes.

## Portabilidade e dependências

- [ ] Expandir a detecção de package managers além de `apt`, `dnf`, `pacman`, `apk`, `zypper`, `pkg` e Cygwin setup.
- [ ] Criar instalador assistido para Kubo/IPFS com seleção automática de arquitetura.
- [ ] Adicionar checks para dependências opcionais como `df`, `awk`, `sed`, `find`, `tar` e `curl`.
- [ ] Documentar diferenças entre GNU/Linux, Termux, Cygwin e RedoxOS.

## Documentação

- [ ] Criar `README.md` com instalação, uso, exemplos e troubleshooting.
- [ ] Documentar as limitações do hash IPFS quando o daemon não está rodando.
- [ ] Adicionar exemplos de saída para modo recursivo e não-recursivo.
- [ ] Explicar como auditar um `.folderstamp` salvo.

## Controle de versão alternativo

- [ ] Melhorar suporte ao Gitoxide para extrair branch/remotes sem depender do Git clássico.
- [ ] Expandir suporte Pijul para registrar remotes, identidade do repositório e mudanças pendentes.
- [ ] Adicionar testes simulando ambientes com apenas `git`, apenas `gix`, apenas `pijul` e nenhum VCS instalado.


## Plataformas adicionais

- [ ] Testar o instalador em macOS real com e sem Homebrew.
- [ ] Testar comandos BSD com `pkg` e `pkg_add` em shells não-GNU.
- [ ] Documentar o que é possível automatizar em Zircon/Fuchsia sem fingir universalidade fake.
